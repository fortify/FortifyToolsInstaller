#!/bin/bash

######################################################################################################
###
### Define the tools that can be installed using this script
###
######################################################################################################

defineTools() {
	# Tool names and their properties can be defines using the following functions:
	#
	# - addToolAliases <toolName> [toolAlias1] [toolAlias2] [...]
	#   Define zero or more aliases for the given <toolName>, allowing users to either 
	#   use a short name for brevity or long name for clarity
	#
	# - setToolDefaultVersion <toolName> <defaultVersion>
	#   Define default version to be used for <toolName> if no version specified
	#
	# - addToolDownloadUrl <toolName> <toolVersion|'default'> <downloadUrl>
	#   Define download URL's for given <toolName>. Different URL's can be specified 
	#   for different tool versions, for example if the download URL for the 'latest'
	#   version is different from download URL's for specific versions. One 'default'
	#   URL can be specified for each tool, which will be used if no version-specific
	#   URL has been configured. The <downloadUrl> may contain properly escaped/quoted
	#   ${toolVersion) variable.
	#
	# For each tool name, the following functions must exist elsewhere in this script:
	#   - installTool_<toolName> <toolAlias> <toolVersion> <toolInstallDir>
	#     Download and install the tool to <toolInstallDir> if it hasn't been
	#     installed yet or if it is being force-installed.
	#   - configureTool_<toolName> <toolAlias> <toolVersion> <toolInstallDir>
	#     Perform any tool configuration tasks like adding environment variables
	#     to VARS_OUT, generating bin-scripts, updating configuration files, ...
	#     This function will also run if an existing installation was found.
	
	addToolAliases        FoDUploader FoDUpload fu
	setToolDefaultVersion FoDUploader latest
	addToolDownloadUrl    FoDUploader default 'https://github.com/fod-dev/fod-uploader-java/releases/download/${toolVersion}/FodUpload.jar'
	addToolDownloadUrl    FoDUploader latest  'https://github.com/fod-dev/fod-uploader-java/releases/latest/download/FodUpload.jar'
	
	addToolAliases        ScanCentralClient ScanCentral sc
	setToolDefaultVersion ScanCentralClient latest
	addToolDownloadUrl    ScanCentralClient default 'https://tools.fortify.com/scancentral/Fortify_ScanCentral_Client_${toolVersion}_x64.zip'
	addToolDownloadUrl    ScanCentralClient latest  'https://tools.fortify.com/scancentral/Fortify_ScanCentral_Client_Latest_x64.zip'
	
	addToolAliases        FortifyVulnerabilityExporter fve
	setToolDefaultVersion FortifyVulnerabilityExporter latest
	addToolDownloadUrl    FortifyVulnerabilityExporter default 'https://github.com/fortify/FortifyVulnerabilityExporter/releases/download/${toolVersion}/FortifyVulnerabilityExporter.zip'
	addToolDownloadUrl    FortifyVulnerabilityExporter latest  'https://github.com/fortify/FortifyVulnerabilityExporter/releases/latest/download/FortifyVulnerabilityExporter.zip'
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
	logError "$@"
	_exit 1
}

# Log info message
# Usage: logInfo <msg>
logInfo() {
	msg "INFO: $@"
}

# Log warn message
# Usage: logWarn <msg>
logWarn() {
	msg "WARN: $@"
}

logError() {
	msg "ERROR: $@"
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

# Execute chmod with the given arguments if installed,
# otherwise log a warning message.
# Usage: _chmod <chmod-args>
_chmod() {
	if isCommand chmod; then
		chmod "$@"
	else 
		logWarn "Command chmod not found, not executing 'chmod $@'"
	fi
}

# Evaluate the given string, expanding any variables contained in the string
# Usage: expandedString=$(evalStringWithVars ${stringWithVars})
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

# Check whether the given function exists
# Usage: checkFunctionExists <functionName>
checkFunctionExists() {
	local fn=$1
	if ! [[ $(type -t ${fn}) == function ]]; then
		exitWithError "Unknown function: $1"
	fi
}


######################################################################################################
###
### Script logic
###
######################################################################################################

# Print an error message followed by usage instructions, then exit the script
# Usage: exitWithUsage "<error message>"
exitWithUsage() {
	msg "ERROR: $@"
	msg ""
	usage
	_exit 1
}

# Print usage instructions
usage() {
	msg "This utility will install and optionally run various Fortify tools that are commonly used in CI/CD pipelines"
	msg ""
	msg "Usage:"
	msg "  ./FortifyToolsInstaller.sh <-h|--help>"
	msg "  [options] source ./FortifyToolsInstaller.sh"
	msg "  [options] source <(curl -sL https://raw.githubusercontent.com/fortify/FortifyToolsInstaller/latest/FortifyToolsInstaller.sh)"
	msg "  [options] source <(curl -sL https://raw.githubusercontent.com/fortify/FortifyToolsInstaller/<version|branch>/FortifyToolsInstaller.sh)"
	msg ""
	msg "[options] is a set of variable definitions. Variables must be specified in either lower case or uppercase"
	msg "case; mixed case variables will not be recognized. Tool aliases are case-insensitive. The following options"
	msg "are recognized by this tool:"
	msg ""
	msg "  FTI_TOOLS=<toolAlias1[:toolVersion]>[,<toolAlias2>[:version][,...]"
	msg "    Required: Define one or more tool aliases and optional tool versions to be installed"
	msg "    Example: FTI_TOOLS=sc,fu:latest,fve:v1.4.1"
	msg "    Supported tools, their aliases and default versions:"
	printSupportedTools
	msg ""
	msg "  FTI_FORCE_INSTALL=true|1"
	msg "    Force tools to be re-downloaded and installed even if they are already installed"
	msg ""
	msg "  FTI_VARS_OUT=export|verify"
	msg "    If set to 'export' (default), output variables will be exported to the shell environment."
	msg "    The 'verify' option is useful when building docker images, to verify that the Dockerfile"
	msg "    contains ENV instructions that match the output variables of FortifyToolsInstaller."
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
	msg ""
	msg "  SCANCENTRAL_CLIENT_AUTH_TOKEN=<token>"
	msg "  SC_CLIENT_AUTH_TOKEN=<token>"
	msg "    Optional ScanCentral client authentication token to be stored in client.properties"
	msg ""
}

# Print list of tools that can be installed using this script, together with tool properties
# like default version and aliases.
# Usage: printSupportedTools
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

# Main function for running this script
# Usage: run
run() {
	local args="$@"
	
	declare -A toolNamesByAlias toolFriendlyAliasesByName toolDefaultVersionsByName toolDownloadUrlsByNameAndVersion
	declare -a toolFriendlyAliases; 
	defineTools
	
	if [[ "$1" == "--help" || "$1" == "-h" ]]; then
		usage
	else 
		# This associative array is used to store environment variables related to the various tools being installed
		declare -A VARS_OUT
		# This array is used to store path entries to be added to the PATH variable
		declare -a PATH_OUT
		defineGenericOutputVars
		installTools
		processVarsOut
	fi
}

# Add tool aliases
# Usage: addToolAliases <toolName> [alias1] [alias2] [...]
addToolAliases() { 
	local toolName=$1; shift;
	addToolAlias ${toolName} ${toolName} # Add toolName as alias for itself
	for toolAlias in "$@"
	do
		addToolAlias ${toolName} ${toolAlias}
	done
}

# Add tool alias
# Usage: addToolAlias <toolName> <toolAlias>
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

# Set tool default version
# Usage: setToolDefaultVersion <toolName> <toolDefaultVersion>
setToolDefaultVersion() {
	local toolName=$1;
	local toolDefaultVersion=$2;
	toolDefaultVersionsByName[${toolName}]=${toolDefaultVersion}
}

# Add tool download URL
# Usage: addToolDownloadUrl <toolName> <toolVersion|'default'> <downloadURL>
addToolDownloadUrl() {
	local toolName=$1;
	local toolVersion=$2;
	local toolDownloadUrl=$3;
	toolDownloadUrlsByNameAndVersion[${toolName}_${toolVersion}]="${toolDownloadUrl}"
}

# Define generic output variables
# Usage: defineGenericOutputVars
defineGenericOutputVars() {
	VARS_OUT[FORTIFY_HOME]=$(getVar FORTIFY_HOME "${HOME}/.fortify")
	VARS_OUT[FORTIFY_TOOLS_DIR]=$(getVar FORTIFY_TOOLS_DIR "$(getVar FORTIFY_HOME)/tools")
	VARS_OUT[FORTIFY_TOOLS_BIN_DIR]=$(getVar FORTIFY_TOOLS_BIN_DIR "$(getVar FORTIFY_TOOLS_DIR)/bin")
	PATH_OUT+=("${VARS_OUT[FORTIFY_TOOLS_BIN_DIR]}")
}

# Install the tools as configured in the FTI_TOOLS variable
# Usage: installTools
installTools() {
	local fciTools=$(getVar FTI_TOOLS)
	[ -z "$fciTools" ] && exitWithUsage "FTI_TOOLS option must be defined"
	mkdir -p $(getVar FORTIFY_TOOLS_BIN_DIR)
	for toolAndVersion in ${fciTools//,/ }; do
		IFS=':' read -r toolAlias toolVersion <<< "$toolAndVersion"
		toolVersion=${toolVersion:-$(getToolDefaultVersion ${toolAlias})}
		installTool "${toolAlias}" "${toolVersion}"
	done
}

# Install the given tool
# Usage: installTool <toolAlias> <toolVersion>
installTool() {
	local toolAlias=$1
	local toolVersion=$2
	local toolName=$(getToolName ${toolAlias})
	local toolInstallDir=$(getToolInstallDir ${toolAlias} ${toolVersion})
	
	local fnInstallTool=$(getToolFunction "installTool" $toolAlias)
	local fnConfigureTool=$(getToolFunction "configureTool" $toolAlias)
	
	if doToolInstall ${toolAlias} ${toolVersion} ${toolInstallDir}; then
		rm -rf "$toolInstallDir" 2> /dev/null
		mkdir -p "$toolInstallDir"
		logInfo "Installing ${toolName}:${toolVersion} to ${toolInstallDir}"
		$fnInstallTool ${toolAlias} ${toolVersion} ${toolInstallDir}
	else
		logInfo "Found existing ${toolName}:${toolVersion} in ${toolInstallDir}"
	fi
	# We always want to run post-install, independent od whether the tools was already installed or not
	$fnConfigureTool ${toolAlias} ${toolVersion} ${toolInstallDir}
}

# Determine whether the given tool needs to be installed
# Usage: if doToolInstall <toolAlias> <toolVersion> <toolInstallDir>; then ...
doToolInstall() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	isVarTrue FTI_FORCE_INSTALL || [[ ! -d "$toolInstallDir" ]] || [[ -z `ls -A "$toolInstallDir"` ]]
}

# Get the tool-specific function for the given tool with the given prefix
# Usage: fn=$(getToolFunction <functionPrefix> <toolAlias>); fn <args>
getToolFunction() {
	local fnPrefix=$1
	local toolAlias=$2
	local toolName=$(getToolName ${toolAlias})
	local fn=${fnPrefix}_${toolName}
	checkFunctionExists $fn
	echo $fn
}

# Get the tool name for the given tool alias
# Usage: toolName=$(getToolName <toolAlias>)
getToolName() {
	local toolAlias=$1
	local toolAliasLowerCase=${toolAlias,,}
	if [ ${toolNamesByAlias[${toolAliasLowerCase}]+_} ]; then
		echo ${toolNamesByAlias[${toolAliasLowerCase}]}
	else
		exitWithError "Unknown tool alias: $toolAlias"
	fi
}

# Get the default tool version for the given tool alias
# Usage: toolDefaultVersion=$(getToolDefaultVersion <toolAlias>)
getToolDefaultVersion() {
	local toolAlias=$1
	local toolName=$(getToolName ${toolAlias})
	if [ ${toolDefaultVersionsByName[${toolName}]+_} ]; then
		echo ${toolDefaultVersionsByName[${toolName}]}
	else
		exitWithError "No default version defined for tool: $toolAlias"
	fi
}

# Get the installation directory for the given tool alias and version
# Usage: toolInstallDir=$(getToolInstallDir <toolAlias> <toolVersion>)
getToolInstallDir() {
	local toolAlias=$1
	local toolVersion=$2
	local toolName=$(getToolName ${toolAlias})
	if [ "${toolVersion}" == "latest" ]; then
		#TODO Make configurable whether to use date-based install dir
		echo "$(getVar FORTIFY_TOOLS_DIR)/${toolName}/latest-$(date +'%Y%m%d')"
	else
		echo "$(getVar FORTIFY_TOOLS_DIR)/${toolName}/${toolVersion}"
	fi
}

# Get the download URL for the given tool alias and version
# Usage: toolDownloadUrl=$(getToolDownloadUrl <toolAlias> <toolVersion>)
getToolDownloadUrl() {
	local toolAlias=$1
	local toolVersion=$2
	local toolName=$(getToolName ${toolAlias})
	local downloadUrlWithVars;
	if [ ${toolDownloadUrlsByNameAndVersion[${toolName}_$toolVersion]+_} ]; then
		downloadUrlWithVars="${toolDownloadUrlsByNameAndVersion[${toolName}_$toolVersion]}"
	elif [ ${toolDownloadUrlsByNameAndVersion[${toolName}_default]+_} ]; then
		downloadUrlWithVars="${toolDownloadUrlsByNameAndVersion[${toolName}_default]}"
	else
		exitWithError "No download URL defined for tool: $toolAlias"
	fi
	evalStringWithVars "${downloadUrlWithVars}"
}

# Process the output variables by exporting them
processVarsOut() {
	if [[ "$FTI_VARS_OUT" == "verify" ]]; then
		verifyVarsOut
		verifyPathOut
	else
		exportVarsOut
		exportPathOut
	fi
}

exportVarsOut() {
	for key in "${!VARS_OUT[@]}"
	do
		export $key="${VARS_OUT[$key]}"
	done
}

exportPathOut() {
	for entry in "${PATH_OUT[@]}"
	do
		[[ "$PATH" == *"$entry"* ]] || export PATH="${PATH}:${entry}"
	done
}

verifyVarsOut() {
	local hasError=0
	for key in "${!VARS_OUT[@]}"
	do
		if [[ -z "${!key}" ]]; then
			logError "Environment variable '${key}' is not defined"
			hasError=1
		elif [[ "${!key}" != "${VARS_OUT[$key]}" ]]; then
			logError "Environment variable '${key}' has unexpected value ${!key}"
			logError=1
		fi
	done
	if [[ "${hasError}" == 1 ]]; then
		logInfo "Expected variable values:"
		for key in "${!VARS_OUT[@]}"
		do
			msg "$key=${VARS_OUT[$key]}"
		done
		_exit 1
	fi
}

verifyPathOut() {
	local hasError=0
	for entry in "${PATH_OUT[@]}"
	do
		if [[ "$PATH" != *"$entry"* ]]; then
			logError "PATH is missing entry '$entry'"
			hasError=1
		fi
	done
	if [[ "${hasError}" == 1 ]]; then
		logInfo "Expected PATH entries:"
		echo $(IFS=: ; echo "${PATH_OUT[*]}")
		_exit 1
	fi
}


######################################################################################################
###
### Functions for installing and configuring FoDUploader
###
######################################################################################################

installTool_FoDUploader() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	local jarFile=${toolInstallDir}/FoDUpload.jar
	local downloadUrl=$(getToolDownloadUrl $toolAlias $toolVersion)
	
	printUrlContents "$downloadUrl" > ${jarFile}
}

configureTool_FoDUploader() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	
	VARS_OUT[FOD_UPLOAD_JAR]="${toolInstallDir}/FoDUpload.jar"
	VARS_OUT[FOD_UPLOAD]="$(getVar FOD_UPLOAD_JAR)" # For backward compatibility with fortify-ci-tools image
	
	local binScript=$(getVar FORTIFY_TOOLS_BIN_DIR)/FoDUpload
	cat <<-EOF > "${binScript}"
		#!/bin/bash
		java -jar "$(getVar FOD_UPLOAD_JAR)" "\$@"
	EOF
	_chmod 755 "${binScript}"
}


######################################################################################################
###
### Functions for installing and configuring ScanCentral Client
###
######################################################################################################

installTool_ScanCentralClient() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	local downloadUrl=$(getToolDownloadUrl $toolAlias $toolVersion)
	unzipUrlContents "$downloadUrl" "${toolInstallDir}"
	_chmod 755 "${toolInstallDir}/bin/packagescanner"
	_chmod 755 "${toolInstallDir}/bin/pwtool"
	_chmod 755 "${toolInstallDir}/bin/scancentral"
}

configureTool_ScanCentralClient() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	
	VARS_OUT[SCANCENTRAL_HOME]="${toolInstallDir}"
	VARS_OUT[SCANCENTRAL_BIN]="$toolInstallDir/bin"
	PATH_OUT+=("${VARS_OUT[SCANCENTRAL_BIN]}")
	
	# Generate or update ScanCentral client.properties file
	local clientAuthToken="$(getVar SC_CLIENT_AUTH_TOKEN $(getVar SCANCENTRAL_CLIENT_AUTH_TOKEN))"
	local clientPropertiesFile=$(getVar SCANCENTRAL_HOME)/Core/config/client.properties
	[ -z "${clientAuthToken}" ] || echo "client_auth_token=${clientAuthToken}" > ${clientPropertiesFile}
}


######################################################################################################
###
### Functions for installing and configuring FortifyVulnerabilityExporter
###
######################################################################################################

installTool_FortifyVulnerabilityExporter() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	local downloadUrl=$(getToolDownloadUrl $toolAlias $toolVersion)
	unzipUrlContents "$downloadUrl" "${toolInstallDir}"
}

configureTool_FortifyVulnerabilityExporter() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	
	VARS_OUT[FVE_HOME]="${toolInstallDir}"
	VARS_OUT[FVE_JAR]="${toolInstallDir}/FortifyVulnerabilityExporter.jar"
	VARS_OUT[FVE_PLUGIN_DIR]="${toolInstallDir}/plugins"
	VARS_OUT[FVE_CFG_DIR]="${toolInstallDir}/config"
	
	local binScript=$(getVar FORTIFY_TOOLS_BIN_DIR)/FortifyVulnerabilityExporter
	cat <<-EOF > "${binScript}"
		#!/bin/bash
		java -DpluginDir="$(getVar FVE_PLUGIN_DIR)" -jar "$(getVar FVE_JAR)" "\$@"
	EOF
	_chmod 755 "${binScript}"
}

run "$@"