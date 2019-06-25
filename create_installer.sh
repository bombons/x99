#!/usr/bin/env bash

# set -x

# get copy of tools
"$(dirname ${BASH_SOURCE[0]})"/get_tools.sh

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/tools/libinstall.sh

warn_about_superuser

if [ "$#" -ne 2 ]; then
    echo "usage: $0 <installer app> <volume>"
    exit 1
fi

if [[ -e "$1" && -e "$2" ]]; then
    app="$1"
    vol="$2"
fi

mountNode=$(df -Hl "$vol" | grep '/dev/disk' | cut -d' ' -f1)

# copy installer image
sudo "$app/Contents/Resources/createinstallmedia" --volume  "$vol" --nointeraction

# rename
sudo diskutil rename $mountNode install_osx
