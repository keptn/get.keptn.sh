#!/bin/sh

KEPTN_VERSION="0.5.2"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
        DISTR="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        DISTR="macOS"
else
       echo "Unknown OS type $OSTYPE"
       exit 1
fi

echo "Downloading keptn $KEPTN_VERSION ..."
curl -L "https://github.com/keptn/keptn/releases/download/${KEPTN_VERSION}/${KEPTN_VERSION}_keptn-${DISTR}.tar" --output keptn-install-${KEPTN_VERSION}.tar

curl_exit_status=$?
if [ $curl_exit_status -eq 1 ]; then
    echo "An error occured while trying to download keptn."
    exit $curl_exit_status
fi

echo "Unpacking ...";
tar -C /tmp -xvf keptn-install-${KEPTN_VERSION}.tar

tar_exit_status=$?
if [ $tar_exit_status -eq 1 ]; then
    echo "An error occured while trying to unpack the archive."
    exit $tar_exit_status
fi

rm keptn-install-${KEPTN_VERSION}.tar

echo "Moving to /usr/local/bin/keptn"
chmod +x /tmp/keptn
mv /tmp/keptn /usr/local/bin/keptn

echo "keptn is now ready!"
