#!/usr/bin/env bash

EXCEPTIONS=""
ESSENTIAL="FakeSMC.kext TSCAdjustReset.kext"
DEPRECATED=""

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/tools/libinstall.sh

warn_about_superuser

# # install tools
install_download_tools

# # remove old/not used kexts
remove_deprecated_kexts

# install required kexts
install_download_kexts
install_tscadjustreset

# LiluFriend and kernel cache rebuild
finish_kexts

# update kexts on EFI/CLOVER/kexts/Other
# update_efi_kexts
