#!/bin/bash

# set -x

# get copy of tools
"$(dirname ${BASH_SOURCE[0]})"/get_tools.sh

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/tools/libdownload.sh

# create _downloads directory and clean
if [[ ! -d ./downloads ]]; then mkdir ./downloads; fi && rm -Rf ./downloads/* && cd ./downloads || exit 1

# download kexts
mkdir ./kexts && cd ./kexts || exit 1
download_rehabman os-x-intel-network RehabMan-IntelMausiEthernet
download_acidanthera Lilu acidanthera-Lilu
download_bombons TSCAdjustReset TSCAdjustReset interferenc-TSCAdjustReset

cd ..

# download tools
mkdir ./tools && cd ./tools || exit 1
download_rehabman os-x-maciasl-patchmatic RehabMan-patchmatic
download_rehabman acpica iasl iasl.zip
cd ..
