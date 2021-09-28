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
	# For each tool name, the following functions may be invoked:
	#   - _preInstall_<toolName> <toolAlias> <toolVersion> <toolInstallDir>
	#     Optional: Commonly used to define script variables used by both the 
	#               _install_<toolName> and _postInstall_<toolName> functions.
	#               If available, this function is always invoked even if the 
	#               tool has already been installed.
	#   - _install_<toolName> <toolAlias> <toolVersion> <toolInstallDir>
	#     Required: Download and install the tool to <toolInstallDir> if it hasn't 
	#              been installed yet or if it is being force-installed.
	#   - _postInstall_<toolName> <toolAlias> <toolVersion> <toolInstallDir>
	#     Optional: Commonly used to perform any post-installation tasks like
	#               updating configuration files and defining output variables.
	#               If available, this function is always invoked even if the 
	#               tool has already been installed.
	
	addToolAliases        FoDUploader FoDUpload fu
	setToolDefaultVersion FoDUploader latest
	addToolDownloadUrl    FoDUploader default 'https://github.com/fod-dev/fod-uploader-java/releases/download/${toolVersion}/FodUpload.jar'
	addToolDownloadUrl    FoDUploader latest  'https://github.com/fod-dev/fod-uploader-java/releases/latest/download/FodUpload.jar'
	addToolSHA256         FoDUploader latest  'f52e070309cc5539ed1937cd16c370ccf5c09d5cf4e80708766ab43959d4fa20'
	addToolSHA256         FoDUploader v5.2.1  'f52e070309cc5539ed1937cd16c370ccf5c09d5cf4e80708766ab43959d4fa20'
	addToolSHA256         FoDUploader v5.2.0  '1e08c0fc1269e39fe502fe3ab301182e2ef2a8884328ac2beec092873d308100'
	addToolSHA256         FoDUploader v5.0.1  'fc31198af03c074bc9190b85d6b9acf42495163f2d7db763c8bb4ed1df6b7d92'
	addToolSHA256         FoDUploader v5.0.0  '7d06869581879ffcb055ab0c2f771d69e21f90caa4a22440d918a2f18b0a3125'
	addToolSHA256         FoDUploader v4.0.4  'adf474e314e2ba2b2e2d8a63ef8e5bc513f49648c1979af2ce04a3191edd6130'
	addToolSHA256         FoDUploader v4.0.3  '4c69b360752a74d5cd728fd8f5b519bbed4af5d6fff47dd3e849a924ba31d0c1'
	addToolSHA256         FoDUploader v4.0.2  '47b3056c7dcee7b790670458f65a21757c422e67b178d6ac907ed32aead004be'
	addToolSHA256         FoDUploader v4.0.1  '7c5abde97d07288ae146160c4eee14091606b26590536b00d5e7b9bba31f0507'
	addToolSHA256         FoDUploader v4.0.0  '6921614493c070d1788c9326a43ce7d65cad5427d7de47dd2548be74c1defa7c'
	
	addToolAliases        ScanCentralClient ScanCentral sc
	setToolDefaultVersion ScanCentralClient latest
	addToolDownloadUrl    ScanCentralClient default 'https://tools.fortify.com/scancentral/Fortify_ScanCentral_Client_${toolVersion}_x64.zip'
	addToolDownloadUrl    ScanCentralClient latest  'https://tools.fortify.com/scancentral/Fortify_ScanCentral_Client_Latest_x64.zip'
	addToolSHA256         ScanCentralClient latest  'c5e431abe19166a4855d1bb4531efdd9f0dd4829777d00d98da330a30d43ca6a'
	addToolSHA256         ScanCentralClient 21.1.2  '313d37acc652edba9657fbc8fed1d811ad0df014636f02314a97865c48244dd6'
	addToolSHA256         ScanCentralClient 20.2.0  'c559e1e08c0d90af71e77bdbb806731f818f59d4b3da7e41c02a307495c38d06'
	addToolSHA256         ScanCentralClient 20.1.0  '4a315c9ab9c61978b47772945e29063545478ae2f0e4574c0111bce891c04eb5'
	
	
	addToolAliases        FortifyVulnerabilityExporter fve
	setToolDefaultVersion FortifyVulnerabilityExporter latest
	addToolDownloadUrl    FortifyVulnerabilityExporter default 'https://github.com/fortify/FortifyVulnerabilityExporter/releases/download/${toolVersion}/FortifyVulnerabilityExporter.zip'
	addToolDownloadUrl    FortifyVulnerabilityExporter latest  'https://github.com/fortify/FortifyVulnerabilityExporter/releases/latest/download/FortifyVulnerabilityExporter.zip'
	addToolSHA256         FortifyVulnerabilityExporter latest  'cc86851b0b5adada0b04f43b93693a637ab3735e85d25246f859535aeb7835cf'
	addToolSHA256         FortifyVulnerabilityExporter v1.5.0  'cc86851b0b5adada0b04f43b93693a637ab3735e85d25246f859535aeb7835cf'
	addToolSHA256         FortifyVulnerabilityExporter v1.4.1  '6e9fa005364513593ab820c79d2c1f05283ff9769fb313c669f0159c395e3d4c'
	addToolSHA256         FortifyVulnerabilityExporter v1.4.0  '63b6e90c5a06f3db6d913121a5fb8a7578d2a1c65a4bdc8cfd6fd0aef286d296'
	addToolSHA256         FortifyVulnerabilityExporter v1.3.1  '8b3f1d8696ed183a9ae0e005bc4165571b0be3e80e59038eb16a446e3ef5e91b'
	addToolSHA256         FortifyVulnerabilityExporter v1.3.0  '28515fd51112b803a1d154884efd3743013895bb3f0037e4eedb2a8b18659bb7'
	addToolSHA256         FortifyVulnerabilityExporter v1.2.1  '1badaf7f91be4482d7666d398893e1b68e24d446811843bee74aea5144f0fe1d'
	addToolSHA256         FortifyVulnerabilityExporter v1.2.0  '05acd1451bcd5b7639e5abb43d42544a6ff5b53d3e9f6c49891094a4d9d6fc6a'
	addToolSHA256         FortifyVulnerabilityExporter v1.1.3  '07b885a3690d111a0bc3b4e40581cd148bd36435255f1a7638c574ebeb8975e1'
	addToolSHA256         FortifyVulnerabilityExporter v1.1.2  '5c27aa10b9fa8cd6b49317543f9fb0ae8e53d6d099f62daadd3b8086f3e56500'
	addToolSHA256         FortifyVulnerabilityExporter v1.1.1  'd27c234a0a85ac79ab0f317777a151b70c8899f3c8bdf909779823555227d98f'
	addToolSHA256         FortifyVulnerabilityExporter v1.1.0  '05a6fed8ded797ab4afb0bdede2a53fa830c218f9944cc076fcaab316505d20d'
	addToolSHA256         FortifyVulnerabilityExporter v1.0.1  '23f499053ed2663084ca509d292d4190c1a609941371d7094a7b3cf474363d4f'
	addToolSHA256         FortifyVulnerabilityExporter v1.0.0  '2edf4bc065e48cb8a2571752dfbe5a944495824e8a3c899e06206a24bf15562c'
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

# Check if single argument is an existing function
# Usage: if isFunction someFunction; then ...
isFunction() {
	[[ $(type -t $1) == function ]] >/dev/null
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
		"${SCRIPT_VARS[$name]}" \
		"${SCRIPT_VARS[$nameUpper]}" \
		"${SCRIPT_VARS[$nameLower]}" \
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
	if ! isFunction $fn; then
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
	msg "Note that as a best practice, you may want to verify the integrity of the script before executing it"
	msg "from a remote location, for example by running sha256sum on the downloaded script and comparing this"
	msg "with a known SHA256 hash."
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
	msg "  FTI_DISABLE_INTEGRITY_CHECK=true|1"
	msg "    Disable integrity check for downloaded tools. It is recommended to leave integrity checks"
	msg "    enabled; also see <toolAlias|toolName>_SHA256 below. Note that hashes for 'latest' versions"
	msg "    may change whenever a new tool version is released, which will cause the integrity check to"
	msg "    fail until this script has been updated with the correct hash."
	msg ""
	msg "  FTI_VARS_OUT=export|verify"
	msg "    If set to 'export' (default), output variables will be exported to the shell environment."
	msg "    The 'verify' option is useful when building docker images, to verify that the Dockerfile"
	msg "    contains ENV instructions that match the output variables of FortifyToolsInstaller."
	msg ""
	msg "  FORTIFY_HOME=</path/to/fortify.home>"
	msg "    Override Fortify home directory, defaults to ~/.fortify"
	msg ""
	msg "  FORTIFY_TOOLS_HOME=</path/to/fortify/tools/dir>"
	msg "    Override Fortify tools directory, defaults to <FORTIFY_HOME>/tools"
	msg "    Tools will be installed to <FORTIFY_TOOLS_HOME>/<toolName>/<toolVersion>"
	msg ""
	msg "  <toolAlias|toolName>_HOME=</path/to/tool/installation/directory>"
	msg "    Override installation directory for the given tool name or alias, defaults to"
	msg "    <FORTIFY_TOOLS_HOME>/<toolName>/<toolVersion>"
	msg ""
	msg "  <toolAlias|toolName>_SHA256=<SHA256 for given tool name being installed>"
	msg "    Override SHA256 hash for the given tool alias or name, for the version specified in the"
	msg "    FTI_TOOLS variable. This may be useful in case this script hasn't been updated yet with"
	msg "    hashes for new tool versions."
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
	
	declare -A toolNamesByAlias toolFriendlyAliasesByName toolDefaultVersionsByName toolDownloadUrlsByNameAndVersion toolSHA256ByNameAndVersion
	declare -a toolFriendlyAliases; 
	defineTools
	
	if [[ "$1" == "--help" || "$1" == "-h" ]]; then
		usage
	else 
		# This associative array is used to store variables shared between various functions
		declare -A SCRIPT_VARS
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

# Add tool SHA256
# Usage: addToolSHA256 <toolName> <toolVersion|'default'> <SHA256>
addToolSHA256() {
	local toolName=$1;
	local toolVersion=$2;
	local toolSHA256=$3;
	toolSHA256ByNameAndVersion[${toolName}_${toolVersion}]="${toolSHA256}"
}

# Define generic output variables
# Usage: defineGenericOutputVars
defineGenericOutputVars() {
	SCRIPT_VARS[FORTIFY_HOME]=$(getVar FORTIFY_HOME "${HOME}/.fortify")
	SCRIPT_VARS[FORTIFY_TOOLS_HOME]=$(getVar FORTIFY_TOOLS_HOME "$(getVar FORTIFY_HOME)/tools")
}

# Install the tools as configured in the FTI_TOOLS variable
# Usage: installTools
installTools() {
	local fciTools=$(getVar FTI_TOOLS)
	[ -z "$fciTools" ] && exitWithUsage "FTI_TOOLS option must be defined"
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
	
	# Get the tool-specific functions. We always run pre-install and post-install
	# functions if available, even if tool is already installed.
	local fnPreInstall=$(getToolFunction "_preInstall" $toolAlias)
	local fnInstall=$(getToolFunction "_install" $toolAlias)
	local fnPostInstall=$(getToolFunction "_postInstall" $toolAlias)
	
	# Install function is required, other functions are optional
	checkFunctionExists $fnInstall
	
	isFunction $fnPreInstall && $fnPreInstall ${toolAlias} ${toolVersion} ${toolInstallDir}
	if doToolInstall ${toolAlias} ${toolVersion} ${toolInstallDir}; then
		rm -rf "$toolInstallDir" 2> /dev/null
		mkdir -p "$toolInstallDir"
		logInfo "Installing ${toolName}:${toolVersion} to ${toolInstallDir}"
		$fnInstall ${toolAlias} ${toolVersion} ${toolInstallDir}
	else
		logInfo "Found existing ${toolName}:${toolVersion} in ${toolInstallDir}"
	fi
	isFunction $fnPostInstall && $fnPostInstall ${toolAlias} ${toolVersion} ${toolInstallDir}
	addOptionalBinDirToPathOut "${toolInstallDir}/bin"
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
	local defaultToolInstallDir;
	if [ "${toolVersion}" == "latest" ]; then
		defaultToolInstallDir="$(getVar FORTIFY_TOOLS_HOME)/${toolName}/latest-$(date +'%Y%m%d')"
	else
		defaultToolInstallDir="$(getVar FORTIFY_TOOLS_HOME)/${toolName}/${toolVersion}"
	fi
	echo $(getVar "${toolAlias}_HOME" $(getVar "${toolName}_HOME" ${defaultToolInstallDir}))
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

# Get the SHA256 for the given tool alias and version
# Usage: toolSHA256=$(getToolSHA256 <toolAlias> <toolVersion>)
getToolSHA256() {
	local toolAlias=$1
	local toolVersion=$2
	local toolName=$(getToolName ${toolAlias})
	local sha256Override=$(getVar "${toolAlias}_SHA256" $(getVar "${toolName}_SHA256" ""))
	if [[ "${sha256Override}" != "" ]]; then
		echo "${sha256Override}"
	elif [ ${toolSHA256ByNameAndVersion[${toolName}_$toolVersion]+_} ]; then
		echo "${toolSHA256ByNameAndVersion[${toolName}_$toolVersion]}"
	else
		exitWithError "No SHA256 hash defined for $toolAlias:$toolVersion"
	fi
}

# Check the SHA256 for the given tool alias and version
# Usage: checkToolSHA256 <toolAlias> <toolVersion> <downloadedFile>
checkToolSHA256() {
	local toolAlias=$1
	local toolVersion=$2
	local toolDownload=$3
	if ! isVarTrue FTI_DISABLE_INTEGRITY_CHECK; then
		local hash=$(sha256sum "$toolDownload" | head -c64)
		local expectedHash=$(getToolSHA256 $toolAlias $toolVersion)
		if [[ "${hash}" != "${expectedHash}" ]]; then
			exitWithError "Got SHA256 hash ${hash} for $toolAlias:$toolVersion, expected ${expectedHash} instead"
		fi
	fi
}

# Download and save the contents for a given tool
# Usage: downloadAndSaveToolContents <toolAlias> <toolVersion> <outputFile>
downloadAndSaveToolContents() {
	local toolAlias=$1
	local toolVersion=$2
	local saveLocation=$3
	local url=$(getToolDownloadUrl $toolAlias $toolVersion)
	printUrlContents "$url" > "$saveLocation"
	checkToolSHA256 $toolAlias $toolVersion "$saveLocation"
}

# Download and unzip the contents for a given tool
# Usage: downloadAndUnzipToolContents <toolAlias> <toolVersion> <unzipDir>
downloadAndUnzipToolContents() {
	local toolAlias=$1
	local toolVersion=$2
	local unzipDir=$3
	local url=$(getToolDownloadUrl $toolAlias $toolVersion)
	local tmpFile=$(_mktemp)
	if ! isCommand unzip; then
		exitWithError "Unzip command must be installed to extract contents from $url"
	fi
	printUrlContents "$url" > "$tmpFile"
	checkToolSHA256 $toolAlias $toolVersion "$tmpFile"
	unzip -qod "$unzipDir" "$tmpFile"
	rm -f "$tmpFile"
}

addOptionalBinDirToPathOut() {
	local binDir=$1
	if [[ -d "${binDir}" ]]; then
		if [[ ! -x "${binDir}" ]]; then
			logWarn "Bin-directory found but not accessible: ${binDir}"
		else
			PATH_OUT+=("${binDir}")
		fi
	fi
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
		# We add each entry to the front of the path, independent of whether it already exists, to make sure latest installation is used
		export PATH="${entry}:${PATH}"
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

_install_FoDUploader() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	local jarFile=${toolInstallDir}/FoDUpload.jar
	
	downloadAndSaveToolContents "$toolAlias" "$toolVersion" "${jarFile}"
	_addBinScript_FoDUploader "${toolInstallDir}" "${jarFile}"
}

_addBinScript_FoDUploader() {
	local toolInstallDir=$1
	local jarFile=$2
	
	local binDir=${toolInstallDir}/bin
	local binScript=${binDir}/FoDUpload
	mkdir -p "${binDir}"
	cat <<-EOF > "${binScript}"
		#!/bin/bash
		java -jar "${jarFile}" "\$@"
	EOF
	_chmod 755 "${binScript}"
}


######################################################################################################
###
### Functions for installing and configuring ScanCentral Client
###
######################################################################################################

_install_ScanCentralClient() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	
	downloadAndUnzipToolContents "$toolAlias" "$toolVersion" "${toolInstallDir}"
	_chmod 755 "${toolInstallDir}/bin/packagescanner"
	_chmod 755 "${toolInstallDir}/bin/pwtool"
	_chmod 755 "${toolInstallDir}/bin/scancentral"
}

_postInstall_ScanCentralClient() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	
	# Generate or update ScanCentral client.properties file
	local clientAuthToken="$(getVar SC_CLIENT_AUTH_TOKEN $(getVar SCANCENTRAL_CLIENT_AUTH_TOKEN))"
	local clientPropertiesFile=${toolInstallDir}/Core/config/client.properties
	[ -z "${clientAuthToken}" ] || echo "client_auth_token=${clientAuthToken}" > ${clientPropertiesFile}
}


######################################################################################################
###
### Functions for installing and configuring FortifyVulnerabilityExporter
###
######################################################################################################

_install_FortifyVulnerabilityExporter() {
	local toolAlias=$1
	local toolVersion=$2
	local toolInstallDir=$3
	
	downloadAndUnzipToolContents "$toolAlias" "$toolVersion" "${toolInstallDir}"
	_addBinScript_FortifyVulnerabilityExporter "${toolInstallDir}" "${toolInstallDir}/FortifyVulnerabilityExporter.jar"
}

_addBinScript_FortifyVulnerabilityExporter() {
	local toolInstallDir=$1
	local jarFile=$2
	
	local binDir=${toolInstallDir}/bin
	local binScript=${binDir}/FortifyVulnerabilityExporter
	mkdir -p "${binDir}"
	cat <<-EOF > "${binScript}"
		#!/bin/bash
		java -DpluginDir="${toolInstallDir}/plugins" -jar "${jarFile}" "\$@"
	EOF
	_chmod 755 "${binScript}"
}

run "$@"