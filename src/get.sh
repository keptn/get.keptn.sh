#!/bin/sh

# Define handy functions
get_latest_version(){
   curl --silent "https://api.github.com/repos/keptn/keptn/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' 
}

print_after_installation_info(){
    printf "Installation is successfully completed!"
    printf "\n"
    printf "You can check Keptn installation by running:"
    printf "\n"
    printf "\n"
    printf "keptn --help"
    printf "\n"
    printf "\n"
    printf "Next step you might be interested in is the installation on your cluster. "
    printf "You can follow the docmentation under https://keptn.sh/docs/ "
    printf "or simply start off by installing Keptn Control Plane via:"
    printf "\n"
    printf "\n"
    printf "keptn install"
    printf "\n"
    printf "\n"
    printf "Also, you can find many helpful tutorials in https://tutorials.keptn.sh/"
    printf "\n"
    printf "Good luck!"
    printf "\n"
}

# Verify curl is installed
if ! [ -x "$(command -v curl)" ]; then
    echo "cURL is not installed! Please install it to continue!"
    exit 1
fi

# If KEPTN_VERSION is not provided -> automatically determine latest version 
if [[ -z "$KEPTN_VERSION" ]]; then
    KEPTN_VERSION=$(get_latest_version)
    printf "The newest version of Keptn is %s and will be used automatically.\n" "${KEPTN_VERSION}"
else
    AVAILABLE_VERSIONS=(`curl --silent "https://api.github.com/repos/keptn/keptn/releases" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'`)
    if [[ ! " ${AVAILABLE_VERSIONS[@]} " =~ " ${KEPTN_VERSION} " ]]; then
        printf "Selected version %s is invalid, please make sure you use proper Keptn tag!\n" "${KEPTN_VERSION}"
        exit 1
    fi
    KEPTN_VERSION=${KEPTN_VERSION}
    printf "We'll install specified Keptn version %s.\n" "${KEPTN_VERSION}"
fi

UNAME="$(uname)"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
        DISTR="linux"
elif [[ "$UNAME" == "Linux" ]]; then
        DISTR="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        DISTR="macOS"
else
       echo "Unknown OS type $OSTYPE"
       exit 1
fi

echo "Downloading keptn $KEPTN_VERSION for $DISTR from GitHub..."
curl -L "https://github.com/keptn/keptn/releases/download/${KEPTN_VERSION}/${KEPTN_VERSION}_keptn-${DISTR}.tar" --output keptn-install-${KEPTN_VERSION}.tar

curl_exit_status=$?
if [ $curl_exit_status -ne 0 ]; then
    echo "An error occured while trying to download keptn."
    exit $curl_exit_status
fi

echo "Unpacking to /tmp ...";
tar -C /tmp -xvf keptn-install-${KEPTN_VERSION}.tar

tar_exit_status=$?
if [ $tar_exit_status -ne 0 ]; then
    echo "An error occured while trying to unpack the archive."
    exit $tar_exit_status
fi

rm keptn-install-${KEPTN_VERSION}.tar

# verifying that /tmp/keptn exists
ls -la /tmp/keptn

if [ $? -ne 0 ]; then
    echo "Keptn was not successfully extracted"
    exit -1
fi

echo "Moving keptn binary to /usr/local/bin/keptn"
chmod +x /tmp/keptn
mv /tmp/keptn /usr/local/bin/keptn

print_after_installation_info
