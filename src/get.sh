#!/bin/sh

# latest GA release
KEPTN_VERSION="0.6.2"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
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

echo "keptn is now ready!"
