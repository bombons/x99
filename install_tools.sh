#!/bin/bash
#set -x

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/tools/libinstall.sh

warn_about_superuser
install_download_tools

#EOF
