#!/bin/bash

########################################################################################################################
# get.keptn.sh / get.sh                                                                                                #
# Quickstart for installing Keptn CLI on several platforms                                                             #
# see https://github.com/keptn/get.keptn.sh for more details                                                           #
#                                                                                                                      #
# This script is licenced under Apache License 2.0, see https://github.com/keptn/get.keptn.sh/blob/master/LICENSE      #
# In addition, parts of this script are copied from or inspired by:                                                    #
# * Istios Quickstart: https://github.com/istio/istio/blob/master/release/downloadIstioCandidate.sh                    #
#                      Apache License 2.0, https://github.com/istio/istio/blob/master/LICENSE                          #
# * Helm Quickstart: https://github.com/helm/helm/blob/master/scripts/get-helm-3                                       #
#                    Apache License 2.0, https://github.com/helm/helm/blob/master/LICENSE                              #
########################################################################################################################

# Define handy functions
get_latest_version(){
   curl --silent "https://api.github.com/repos/keptn/keptn/releases/latest" | grep tag_name | awk 'match($0, /[0-9]+.[0-9]+.[0-9]+[.\-A-Za-z0-9]*/) { print substr( $0, RSTART, RLENGTH )}'
}

get_all_versions(){
    curl --silent "https://api.github.com/repos/keptn/keptn/releases" | grep tag_name | awk 'match($0, /[0-9]+.[0-9]+.[0-9]+[.\-A-Za-z0-9]*/) { print substr( $0, RSTART, RLENGTH )}'
}

print_after_installation_info(){
    TARGET_DIR=${1:-""}

    printf "\n"
    printf "Installation is successfully completed!"
    printf "\n"
    printf "You can check Keptn installation by running:"
    printf "\n"
    printf "\n"
    printf "${TARGET_DIR}keptn --help"
    printf "\n"
    printf "\n"
    printf "Next step you might be interested in is the installation on your cluster. "
    printf "You can follow the docmentation under https://keptn.sh/docs/ "
    printf "or simply start off by installing Keptn Control Plane via:"
    printf "\n"
    printf "\n"
    printf "${TARGET_DIR}keptn install"
    printf "\n"
    printf "\n"
    printf "Also, you can find many helpful tutorials in https://tutorials.keptn.sh/"
    printf "\n"
    printf "Good luck!"
    printf "\n"
}

runAsRoot() {
    CMD="$*"

    if [[ $EUID == 0 ]] || [[ ${USE_SUDO} == "false" ]]; then
        $CMD
    else
        echo "Trying to run $CMD with sudo..."
        sudo $CMD
    fi
}

# Verify sudo is available
if ! [ -x "$(command -v sudo)" ]; then
    echo "sudo is not available! Installation might fail..."
    USE_SUDO=false
fi

# Verify curl is installed
if ! [ -x "$(command -v curl)" ]; then
    echo "cURL is not installed! Please install it to continue!"
    exit 1
fi

# Verify tar is installed
if ! [ -x "$(command -v tar)" ]; then
    echo "tar is not installed! Please install it to continue!"
    exit 1
fi

# Verify awk is installed
if ! [ -x "$(command -v awk)" ]; then
    echo "awk is not installed! Please install it to continue!"
    exit 1
fi

# If KEPTN_VERSION is not provided -> automatically determine latest version 
if [[ -z "$KEPTN_VERSION" ]]; then
    KEPTN_VERSION=$(get_latest_version)
    printf "The newest version of Keptn is %s and will be used automatically\n" "${KEPTN_VERSION}"
else
    AVAILABLE_VERSIONS=(`get_all_versions`)
    if [[ ! " ${AVAILABLE_VERSIONS[@]} " =~ " ${KEPTN_VERSION} " ]]; then
        printf "Selected version %s is invalid, please make sure you use proper Keptn release version!\n" "${KEPTN_VERSION}"
        echo "Available versions are: ${AVAILABLE_VERSIONS[@]}"
        exit 1
    fi
    KEPTN_VERSION=${KEPTN_VERSION}
    printf "We'll install specified Keptn version %s\n" "${KEPTN_VERSION}"
fi


# Detect Operating System
UNAME="$(uname)"

# see https://stackoverflow.com/a/8597411 for some more info
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    DISTR="linux"
elif [[ "$UNAME" == "Linux" ]]; then
    DISTR="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then # mac os
    DISTR="macOS"
elif [[ "$OSTYPE" == "mingw"* ]] || [[ "$OSTYPE" == "msys" ]]; then # some sort of bash on windows
    DISTR="windows"
else
    echo "Unknown OS type $OSTYPE. Please manually download a release from https://github.com/keptn/keptn/releases."
    exit 1
fi

# if TARGET_ARCH is not provided, determine it using uname -m
if [[ -z "$TARGET_ARCH" ]]; then
    TARGET_ARCH=$(uname -m)
    printf "Determined target architecture %s\n" "$TARGET_ARCH"
else
    printf "Using provided target architecture %s\n" "$TARGET_ARCH"
fi

if [[ "$TARGET_ARCH" == "x86_64" ]] || [[ "$TARGET_ARCH" == "amd64" ]]; then
    KEPTN_ARCH="amd64"
elif [[ "$TARGET_ARCH" == "armv8"* ]] || [[ "$TARGET_ARCH" == "aarch64"* ]] || [[ "$TARGET_ARCH" == "arm64" ]]; then
    KEPTN_ARCH="arm64"
elif [[ "$TARGET_ARCH" == "i386" ]] || [[ "$TARGET_ARCH" == "386" ]]; then
    KEPTN_ARCH="386"
else
    echo "Unsupported target architecture $TARGET_ARCH. Please manually download a release from https://github.com/keptn/keptn/releases."
    exit 1
fi

# allow customizing install directory
if [[ -z "$INSTALL_DIRECTORY" ]]; then
    # if we are not on windows, we know that we should install to /usr/local/bin
    if [[ "$DISTR" != "windows" ]]; then
        INSTALL_DIRECTORY="/usr/local/bin"
    fi
fi

# Keptn 0.8.0-alpha and above support arch, strip MAJOR and MINOR version so we can compare it
ARCH_UNSUPPORTED_MAJOR_MINOR="0.8"
KEPTN_VERSION_MAJOR_MINOR=$(echo "$KEPTN_VERSION" | awk 'match($0, /[0-9]+.[0-9]+*/) { print substr( $0, RSTART, RLENGTH )}' )

if [ "$(expr "${KEPTN_VERSION_MAJOR_MINOR}" \>= "${ARCH_UNSUPPORTED_MAJOR_MINOR}")" -eq 1 ]; then
    # for Keptn 0.8.x and newer we the format is: keptn-${KEPTN_VERSION}-${DISTR}-${KEPTN_ARCH}.tar.gz
    FILENAME="keptn-${KEPTN_VERSION}-${DISTR}-${KEPTN_ARCH}.tar.gz"
    BINARY_NAME="keptn-${KEPTN_VERSION}-${DISTR}-${KEPTN_ARCH}*"
else
    # for Keptn 0.7.x and older we need to try the old format: ${KEPTN_VERSION}_keptn-${DISTR}.tar
    FILENAME="${KEPTN_VERSION}_keptn-${DISTR}.tar"
    BINARY_NAME="keptn"
fi

# ensure binary name is properly set for windows
if [[ "$DISTR" == "windows" ]]; then
    BINARY_NAME="${BINARY_NAME}.exe"
fi

URL="https://github.com/keptn/keptn/releases/download/${KEPTN_VERSION}/${FILENAME}"

echo "Downloading keptn $KEPTN_VERSION for OS $DISTR with architecture $KEPTN_ARCH from GitHub: $URL"
curl --fail -L "${URL}" --output ${FILENAME}

curl_exit_status=$?
if [ $curl_exit_status -ne 0 ]; then
    LATEST_KEPTN_VERSION=$(get_latest_version)
    echo "An error occured while trying to download keptn from GitHub. Please manually download a release from https://github.com/keptn/keptn/releases."
    exit $curl_exit_status
fi

echo "Unpacking archive ${FILENAME} in current directory ...";
tar -xvf ${FILENAME}

tar_exit_status=$?
if [ $tar_exit_status -ne 0 ]; then
    echo "An error occured while trying to unpack the archive."
    exit $tar_exit_status
fi

# Cleanup: remove the archive
rm ${FILENAME}

# verifying that the binary exists
ls -la ${BINARY_NAME}

if [ $? -ne 0 ]; then
    echo "Keptn binary ${BINARY_NAME} was not successfully extracted"
    exit -1
fi

# make sure the binary is executable
chmod +x ${BINARY_NAME}

if [[ -z ${INSTALL_DIRECTORY} ]]; then
    echo "Keptn CLI has been downloaded to your current working directory."

    # print some additional info
    print_after_installation_info "./"
else
    # Move it to an installable directory
    echo "Moving keptn binary to ${INSTALL_DIRECTORY}"
    runAsRoot mv ${BINARY_NAME} ${INSTALL_DIRECTORY}/keptn

    if [ $? -ne 0 ]; then
        echo "Error: Could not move keptn binary to /usr/local/bin"
        exit -1
    fi

    # print some additional info
    print_after_installation_info
fi


