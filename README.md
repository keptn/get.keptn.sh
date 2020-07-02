# get.keptn.sh repository

This repo is part of the [Keptn Project](https://keptn.sh) and provides the following two files:

* [version.json](src/version.json) - contains information about the available Keptn versions, published to https://get.keptn.sh/version.json
* [get.sh](src/get.sh) - auto installation script for the keptn CLI (for osx and linux) which is published on `https://get.keptn.sh` (e.g., run `curl -sL https://get.keptn.sh | sudo -E bash`)

## Process Details

If a new Keptn GA release is published on GitHub we will create a Pull Request in this repo with the the updated version of `get.sh` and `version.json`. Once this is merged, the changes should be uploaded to `https://get.keptn.sh`.

## get.sh params

Currently, the following parameters are available:

* `KEPTN_VERSION` (points to a GitHub Release of [keptn/keptn](https://github.com/keptn/keptn/releases)), e.g., `0.6.2`

# License

Please see [LICENSE](LICENSE).