#!/usr/bin/env bash

# set -x

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/tools/libinstall.sh
source "$(dirname ${BASH_SOURCE[0]})"/tools/colors.sh
warn_about_superuser
activate_colors

function pure_version() {
    echo '1.0.0'
}

function version() {
    echo "$(basename $0) $(pure_version)"
}

function usage() {
    version
    echo " --version"
    echo "   show tool version number"
    echo " -h, --help"
    echo "   display this help"
    exit 0
}

function install_aml
{
    echo "${BLUE}==>${RESET} installing $1 to "$EFIDIR"/EFI/CLOVER/ACPI/patched"
    cp -a "$1" "$EFIDIR"/EFI/CLOVER/ACPI/patched
}

test "$#" = "0" && {
    echo "No arguments supplied. Invoke with --help for help."
    exit 1
}

while test "${1:0:1}" = "-"; do
    case "$1" in
        -x99aii)
            options=( $(find . -type f -maxdepth 1 -iname '*.aml' -print0 |  xargs -0) )
            shift;
            ;;
        -h | --help)
            usage ;;
        --version)
            version
            exit 0 ;;
        -*)
            echo "Unknown option $1. Run with --help for help."
            exit 1 ;;
    esac
done

EFIDIR=$(./mount_efi.sh)
rm -f "$EFIDIR"/EFI/CLOVER/ACPI/patched/SSDT-*.aml


EXCEPTIONS="ACQU|Nvidia|P2EI0G|RadeonVII|RX560|RX580|TB3HP|Vega-Fontier|Vega64|X540"
for aml in "${options[@]}"
do

    aml_file="$(echo "$aml" | cut -c 3-)"

    if [[ "$EXCEPTIONS" == "" || "`echo $aml_file | grep -vE "$EXCEPTIONS"`" != "" ]]; then
        install_aml "$aml_file"
    fi

done
