#!/bin/bash

######################################################################################################
###
### Defining available tool aliases, default versions, download URL's, and output variables
###
######################################################################################################

defineTools() {
	# Define available tool names and their aliases; aliases allow users to either use a short name for brevity 
	# or long name for clarity. For each tool name, the following functions must exist:
	#   - install_<toolName>
	#   - updateVars_<toolName>
	#   - run_<toolName>
	# Syntax for adding a tool with aliases:
	#   addToolAliases <toolName> [toolAlias1] [toolAlias2] [...]
	addToolAliases FoDUploader FoDUpload fu
	addToolAliases ScanCentralClient ScanCentral sc
	addToolAliases FortifyVulnerabilityExporter fve

	# Map tool names (matching toolNamesByAlias array values) to default version for that particular tool.
	toolDefaultVersionsByName[FoDUploader]=latest
	toolDefaultVersionsByName[ScanCentralClient]=latest
	toolDefaultVersionsByName[FortifyVulnerabilityExporter]=latest

	# Map tool names and optional version to download URL's.
	# Array keys are in the format <toolName>[_<toolVersion>]; the optional version allows for specifying
	# different download URL's for specific versions.
	# Array values contain the actual download URL's, and may contain escaped/quoted ${toolVersion} variable.
	toolDownloadUrlsByNameAndVersion[FoDUploader]='https://github.com/fod-dev/fod-uploader-java/releases/download/${toolVersion}/FodUpload.jar'
	toolDownloadUrlsByNameAndVersion[FoDUploader_latest]='https://github.com/fod-dev/fod-uploader-java/releases/latest/download/FodUpload.jar'
	toolDownloadUrlsByNameAndVersion[ScanCentralClient]='https://tools.fortify.com/scancentral/Fortify_ScanCentral_Client_${toolVersion}_x64.zip'
	toolDownloadUrlsByNameAndVersion[ScanCentralClient_latest]='https://tools.fortify.com/scancentral/Fortify_ScanCentral_Client_Latest_x64.zip'
	toolDownloadUrlsByNameAndVersion[FortifyVulnerabilityExporter]='https://github.com/fortify/FortifyVulnerabilityExporter/releases/download/${toolVersion}/FortifyVulnerabilityExporter.zip'
	toolDownloadUrlsByNameAndVersion[FortifyVulnerabilityExporter_latest]='https://github.com/fortify/FortifyVulnerabilityExporter/releases/latest/download/FortifyVulnerabilityExporter.zip'
}

######################################################################################################
###
### Generic utility functions
###
######################################################################################################

# Exit script, providing the following advantages over a regular 'exit':
#   - Doesn't exit shell if script is being sourced
#   - Script exits immediately even if _exit is called from a 
#     function running in a subshell, i.e. no need to do
#     $(getXXX a b c) || exit $?
_exit() {
	kill -INT $$
}

# Print a message to stderr
msg() { 
	cat <<< "$@" >&2; 
}

# Exit with an error code after printing an error message
# Usage: exitWithError <msg>
exitWithError() {
	msg "ERROR: $@"
	_exit 1
}

# Log info message
# Usage: logInfo <msg>
logInfo() {
	msg "INFO: $@"
}

# Check if single argument is an existing command
# Usage: if isCommand someCommand; then ...
isCommand() {
	command -v "$1" >/dev/null
}

# Print the contents of a given URL, using either wget or curl
# Exit with an error if neither wget or curl are available
# Usage: printUrlContents <url>
printUrlContents() {
	local url=$1
	if isCommand wget; then
		wget -qO- $url || exitWithError "Error accessing ${url}"
	elif isCommand curl; then
		curl -sL $url || exitWithError "Error accessing ${url}"
	else 
		exitWithError "Either wget or curl must be installed to download files"
	fi
}

# Unzip the contents of a given URL
# Usage: unzipUrlContents <url> <unzipDir>
unzipUrlContents() {
	local url=$1
	local unzipDir=$2
	local tmpFile=$(_mktemp)
	if ! isCommand unzip; then
		exitWithError "Unzip command must be installed to extract contents from $url"
	fi
	printUrlContents "$url" > "$tmpFile"
	unzip -qod "$unzipDir" "$tmpFile"
	rm -f "$tmpFile"
}

# Get a temporary file name
# Usage: myTempFile=$(_mktemp)
_mktemp() {
	if isCommand mktemp; then
		mktemp
	else 
		mkdir -p "$FORTIFY_HOME/tmp"
		echo "$FORTIFY_HOME/tmp/fti_tmp_$$"
	fi
}

evalStringWithVars() {
	stringWithVars=$1
	echo $(source <(echo "echo \"${stringWithVars}\""))
}

# Get input value from either VARS_OUT or regular (environment) variables,
# using both uppercase and lowercase lookup
# Usage: myVar=$(getVar <someVariableName>)
getVar() {
	local name=$1
	local defaultValue=$2
	local nameUpper=${name^^}
	local nameLower=${name,,}
	
	echoFirstNotBlank \
		"${VARS_OUT[$name]}" \
		"${VARS_OUT[$nameUpper]}" \
		"${VARS_OUT[$nameLower]}" \
		"${!name}" \
		"${!nameUpper}" \
		"${!nameLower}" \
		"$defaultValue"
}

# Echo first non-blank parameter value
# Usage: echoFirstNotBlank "${someVar}" "${someOtherVar}" "${someThirdVar}"
echoFirstNotBlank() {
	for value in "$@"
	do
		[ -n "${value}" ] && echo ${value} && break
	done
}

# Check whether the given value equals either 'true' (case-insensitive) or '1'
# Usage: isTrue <value>
isTrue() {
	value=$1
	[[ "${value,,}" == "true" || "${value}" == "1" ]]
}

# Check whether the value for the given variable name equals either 'true' (case-insensitive) or '1'
# Usage: isVarTrue <variableName>
isVarTrue() {
	var=$1
	isTrue $(getVar $var)
}


######################################################################################################
###
### Script logic
###
######################################################################################################

exitWithUsage() {
	msg "ERROR: $@"
	msg ""
	usage
	_exit 1
}

usage() {
	msg "This utility will install and optionally run various Fortify tools that are commonly used in CI/CD pipelines"
	msg ""
	msg "Usage:"
	msg "  [options] ./FortifyToolsInstaller.sh [-h|--help]"
	msg "  [options] source <(curl -sL https://raw.githubusercontent.com/fortify/FortifyToolsInstaller/main/FortifyToolsInstaller.sh)"
	msg ""
	msg "[options] is a set of variable definitions. Variables must be specified in either lower case or uppercase"
	msg "case; mixed case variables will not be recognized. Tool aliases are case-insensitive. The following options"
	msg "are recognized by this tool:"
	msg ""
	msg "  FTI_TOOLS=<toolAlias1[:toolVersion]>[,<toolAlias2>[:version][,...]"
	msg "    Required: Define one or more tool aliases and optional tool versions to be installed and/or run"
	msg "              If corresponding FTI_RUN_<toolAlias> or FTI_<toolAlias>_ARGS have been defined, the"
	msg "              tool will be installed (if necessary) and then run immediately. Otherwise, the tool"
	msg "              will be installed for later use, without actually running it."
	msg "    Example: FTI_TOOLS=sc,fu:latest,fve:v1.4.1"
	msg "    Supported tools, their aliases and default versions:"
	printSupportedTools
	msg ""
	msg "  FTI_RUN_<toolAlias>=true|1"
	msg "    Run the tool identified by <toolAlias> without any arguments. <toolAlias> must matching with one of"
	msg "    the tool aliases listed in FTI_TOOLS."
	msg ""
	msg "  FTI_<toolAlias>_ARGS=\"<toolArg1> [toolArg2] [...]\""
	msg "    Run the tool identified by <toolAlias> with the specified command line arguments"
	msg ""
	msg "  FTI_FORCE_INSTALL=true|1"
	msg "    Force tools to be re-downloaded and installed even if they are already installed"
	msg ""
	msg "  FORTIFY_HOME=</path/to/fortify.home>"
	msg "    Override Fortify home directory, defaults to ~/.fortify"
	msg ""
	msg "  FORTIFY_TOOLS_DIR=</path/to/fortify/tools/dir>"
	msg "    Override Fortify tools directory, defaults to <FORTIFY_HOME>/tools"
	msg "    Tools will be installed to <FORTIFY_TOOLS_DIR>/<toolName>/<toolVersion>"
	msg ""
	msg "  FORTIFY_TOOLS_BIN_DIR=</path/to/fortify/tools/bin/dir>"
	msg "    Override Fortify tools bin directory, defaults to <FORTIFY_TOOLS_DIR>/bin"
	msg "    Path where scripts and symbolic links to various Fortify tools will be installed"
}

printSupportedTools() {
	for toolName in "${!toolFriendlyAliasesByName[@]}"
	do
		local toolDefaultVersion=${toolDefaultVersionsByName[${toolName}]}
		local toolAliases=${toolFriendlyAliasesByName[${toolName}]}
		msg "      ${toolName}"
		msg "        Aliases: ${toolAliases}"
		msg "        Default version: ${toolDefaultVersion}"
	done
}

addToolAlias() {
	local toolName=$1; local toolFriendlyAlias=$2
	toolNamesByAlias[${toolFriendlyAlias,,}]=${toolName}
	toolFriendlyAliases+=( ${toolFriendlyAlias} )
	if [ -z "${toolFriendlyAliasesByName[${toolName}]+_}" ]; then
		toolFriendlyAliasesByName[${toolName}]="${toolFriendlyAlias}"
	else 
		toolFriendlyAliasesByName[${toolName}]+=", ${toolFriendlyAlias}"
	fi
}

addToolAliases() { 
	local toolName=$1; shift;
	addToolAlias ${toolName} ${toolName}
	for toolAlias in "$@"
	do
		addToolAlias ${toolName} ${toolAlias}
	done
}

run() {
	# This associative array is used to store environment variables related to the various tools being installed
	declare -A toolNamesByAlias toolFriendlyAliasesByName toolDefaultVersionsByName toolDownloadUrlsByNameAndVersion
	declare -a toolFriendlyAliases; 
	declare -A VARS_OUT
	defineTools
	defineGlobalVars
	installAndRunTools
	processVarsOut
}

defineGlobalVars() {
	VARS_OUT[FORTIFY_HOME]=$(getVar FORTIFY_HOME "${HOME}/.fortify")
	VARS_OUT[FORTIFY_TOOLS_DIR]=$(getVar FORTIFY_TOOLS_DIR "$(getVar FORTIFY_HOME)/tools")
	VARS_OUT[FORTIFY_TOOLS_BIN_DIR]=$(getVar FORTIFY_TOOLS_BIN_DIR "$(getVar FORTIFY_TOOLS_DIR)/bin")
	VARS_OUT[PATH]="${PATH}:${VARS_OUT[FORTIFY_TOOLS_BIN_DIR]}"
}

installAndRunTools() {
	local fciTools; fciTools=$(getVar FTI_TOOLS)
	if [ -z "$fciTools" ]; then
		exitWithUsage "FTI_TOOLS option must be defined"
	fi
	for toolAndVersion in ${fciTools//,/ }; do
		installAndRunTool "${toolAndVersion}"
	done
}

processVarsOut() {
	for key in "${!VARS_OUT[@]}"
	do
		export $key="${VARS_OUT[$key]}"
	done
}

installAndRunTool() {
	local toolAndVersion=$1
	IFS=':' read -r toolAlias toolVersion <<< "$toolAndVersion"
	toolVersion=${toolVersion:-$(getToolDefaultVersion ${toolAlias})}
	installTool "${toolAlias}" "${toolVersion}"
	runTool "${toolAlias}" "${toolVersion}"
}

installTool() {
	local toolAlias=$1
	local toolVersion=$2
	local toolName; toolName=$(getToolName ${toolAlias})
	local toolInstallDir; toolInstallDir=$(getToolInstallDir ${toolAlias} ${toolVersion})
	
	if isVarTrue FTI_FORCE_INSTALL || [[ ! -d "$toolInstallDir" ]] || [[ -z `ls -A "$toolInstallDir"` ]]; then
		rm -rf "$toolInstallDir" 2> /dev/null
		mkdir -p "$toolInstallDir"
		logInfo "Installing ${toolName}:${toolVersion} to ${toolInstallDir}"
		local fnInstall; fnInstall=$(getToolFunction "install" $toolAlias)
		$fnInstall ${toolAlias} ${toolVersion} ${toolInstallDir}
	else
		logInfo "Found existing ${toolName}:${toolVersion} in ${toolInstallDir}"
	fi
	local fnUpdateVars; fnUpdateVars=$(getToolFunction "updateVars" $toolAlias)
	$fnUpdateVars ${toolAlias} ${toolVersion} ${toolInstallDir}
}

runTool() {
	local toolAlias=$1
	local toolVersion=$2
	local toolArgs=$(getVar "FTI_${toolAlias}_ARGS")
	if isVarTrue "FTI_RUN_${toolAlias}" || [[ "${toolArgs}" ]]; then
		local toolName; toolName=$(getToolName ${toolAlias})
		local fn; fn=$(getToolFunction "run" $toolAlias)
		logInfo "Running ${toolName}:${toolVersion}"
		$fn ${toolAlias} ${toolArgs}
	fi
}

getToolFunction() {
	local fnPrefix=$1
	local toolAlias=$2
	local toolName; toolName=$(getToolName ${toolAlias})
	local fn=${fnPrefix}_${toolName}
	checkFunctionExists $fn
	echo $fn
}

getToolName() {
	local toolAlias=$1
	local toolAliasLowerCase=${toolAlias,,}
	if [ ${toolNamesByAlias[${toolAliasLowerCase}]+_} ]; then
		echo ${toolNamesByAlias[${toolAliasLowerCase}]}
	else
		exitWithError "Unknown tool alias: $toolAlias"
	fi
}

getToolDefaultVersion() {
	local toolAlias=$1
	local toolName; toolName=$(getToolName ${toolAlias})
	if [ ${toolDefaultVersionsByName[${toolName}]+_} ]; then
		echo ${toolDefaultVersionsByName[${toolName}]}
	else
		exitWithError "No default version defined for tool: $toolAlias"
	fi
}

getToolInstallDir() {
	local toolAlias=$1
	local toolVersion=$2
	local toolName; toolName=$(getToolName ${toolAlias})
	if [ "${toolVersion}" == "latest" ]; then
		#TODO Make configurable whether to use date-based install dir
		echo "$(getVar FORTIFY_TOOLS_DIR)/${toolName}/latest-$(date +'%Y%m%d')"
	else
		echo "$(getVar FORTIFY_TOOLS_DIR)/${toolName}/${toolVersion}"
	fi
}

getToolDownloadUrl() {
	local toolAlias=$1
	local toolVersion=$2
	local toolName; toolName=$(getToolName ${toolAlias})
	local downloadUrlWithVars;
	if [ ${toolDownloadUrlsByNameAndVersion[${toolName}_$toolVersion]+_} ]; then
		downloadUrlWithVars="${toolDownloadUrlsByNameAndVersion[${toolName}_$toolVersion]}"
	elif [ ${toolDownloadUrlsByNameAndVersion[${toolName}]+_} ]; then
		downloadUrlWithVars="${toolDownloadUrlsByNameAndVersion[${toolName}]}"
	else
		exitWithError "No download URL defined for tool: $toolAlias"
	fi
	evalStringWithVars "${downloadUrlWithVars}"
}

checkFunctionExists() {
	local fn=$1
	if ! [[ $(type -t ${fn}) == function ]]; then
		exitWithError "Unknown function: $1"
	fi
}


######################################################################################################
###
### Functions for installing and running FoDUploader
###
######################################################################################################

install_FoDUploader() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	local jarFile=${toolInstallDir}/FoDUpload.jar
	local downloadUrl; downloadUrl=$(getToolDownloadUrl $toolAlias $toolVersion)
	
	printUrlContents "$downloadUrl" > ${jarFile}
}

updateVars_FoDUploader() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	VARS_OUT[FOD_UPLOAD]="${toolInstallDir}/FoDUpload.jar"
}

run_FoDUploader() {
	local toolAlias=$1; shift;
	local jarFile=${VARS_OUT[FOD_UPLOAD]}
	
	java -jar "$jarFile" "$@"
}


######################################################################################################
###
### Functions for installing and running ScanCentral Client
###
######################################################################################################

install_ScanCentralClient() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	local downloadUrl; downloadUrl=$(getToolDownloadUrl $toolAlias $toolVersion)
	unzipUrlContents "$downloadUrl" "${toolInstallDir}"
	chmod 555 "${toolInstallDir}/bin/packagescanner"
	chmod 555 "${toolInstallDir}/bin/pwtool"
	chmod 555 "${toolInstallDir}/bin/scancentral"
}

updateVars_ScanCentralClient() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	VARS_OUT[SCANCENTRAL_BIN]="$toolInstallDir/bin"
	VARS_OUT[PATH]="${VARS_OUT[PATH]}:${VARS_OUT[SCANCENTRAL_BIN]}"
}

run_ScanCentralClient() {
	local toolAlias=$1; shift;
	local binDir=${VARS_OUT[SCANCENTRAL_BIN]}
	${binDir}/scancentral "$@"
}


######################################################################################################
###
### Functions for installing and running FortifyVulnerabilityExporter
###
######################################################################################################

install_FortifyVulnerabilityExporter() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	local downloadUrl; downloadUrl=$(getToolDownloadUrl $toolAlias $toolVersion)
	unzipUrlContents "$downloadUrl" "${toolInstallDir}"
}

updateVars_FortifyVulnerabilityExporter() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	VARS_OUT[FVE_HOME]="${toolInstallDir}"
	VARS_OUT[FVE_JAR]="${toolInstallDir}/FortifyVulnerabilityExporter.jar"
	VARS_OUT[FVE_PLUGINS]="${toolInstallDir}/plugins"
	VARS_OUT[FVE_CFG]="${toolInstallDir}/config"
}

run_FortifyVulnerabilityExporter() {
	local toolAlias=$1; shift;
	local configFile=$1; shift;
	local jarFile=${VARS_OUT[FVE_JAR]}
	local pluginDir=${VARS_OUT[FVE_PLUGINS]}
	if [[ ${configFile} != /* ]]; then
		configFile=${VARS_OUT[FVE_CFG]}/$configFile
	fi
	if [ ! -f "${configFile}" ]; then
		exitWithError "ERROR: Configuration file ${configFile} does not exist"
	fi
	java -DpluginDir=${pluginDir} -jar "${jarFile}" --export.config=${configFile} "$@"
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
	usage
else 
	run
fi