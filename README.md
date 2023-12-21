# get.keptn.sh repository

## Keptn V1 has reached end of life on December 22nd, 2023 and has been [replaced](https://github.com/keptn/lifecycle-toolkit).

This repo is part of the [Keptn Project](https://keptn.sh) and provides the following two files:

* [version.json](src/version.json) - contains information about the available Keptn versions, published to https://get.keptn.sh/version.json
* [get.sh](src/get.sh) - auto installation script for the keptn CLI which is published on `https://get.keptn.sh` (e.g., run `curl -sL https://get.keptn.sh | bash`)

## Process Details

If a new Keptn GA release is published on GitHub we will create a Pull Request in this repo with the the updated version of `version.json`. Once this is merged, the changes will be automatically uploaded to `https://get.keptn.sh`.

## get.sh params

Currently, the following parameters are available:

* `KEPTN_VERSION` - Optional; points to a GitHub Release of [keptn/keptn](https://github.com/keptn/keptn/releases), e.g., `0.7.0`; default: latest release
* `TARGET_ARCH` - specifies the target CPU architecture, e.g., amd64; default: amd64
* `INSTALL_DIRECTORY` - specifies the installation directory (default for Linux/MacOS: `/usr/local/bin`); if unset, `keptn` cli binary will stay in current working directory

### Examples

1. Install the latest stable version for the current operating system and CPU architecture
   ```console
   curl -sL https://get.keptn.sh | bash
   ```
1. Install an alpha version
   ```console
   curl -sL https://get.keptn.sh | KEPTN_VERSION=0.8.0-alpha bash
   ```
1. Install the latest stable version for amd64
   ```console
   curl -sL https://get.keptn.sh | TARGET_ARCH=amd64 bash
   ```


## version.json

The file [version.json](src/version.json) contains information about the latest versions available and upgradepaths.

# License

Please see [LICENSE](LICENSE).
