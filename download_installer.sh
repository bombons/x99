#!/usr/bin/env bash

# set -x;

TMP_DIR=/tmp/com.bombons.support
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SEEDCATALOGS='/System/Library/PrivateFrameworks/Seeding.framework/Versions/A/Resources/SeedCatalogs.plist'
DEFAULT_SUCATALOGS='https://swscan.apple.com/content/catalogs/others/index-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog'
# DEFAULT_SUCATALOGS='https://swscan.apple.com/content/catalogs/others/index-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog'

# get copy of tools
"$(dirname ${BASH_SOURCE[0]})"/get_tools.sh

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/tools/libinstall.sh
source "$(dirname ${BASH_SOURCE[0]})"/tools/libinstaller.sh

warn_about_superuser


# # start clean
# mkdir -p $TMP_DIR && rm -Rf $TMP_DIR/*
cd $TMP_DIR || exit 1

# # download sucatalog
# download $DEFAULT_SUCATALOGS

# convert to plain text if necessary
plutil_convert "$(basename $DEFAULT_SUCATALOGS)"
plutil_check "$(basename $DEFAULT_SUCATALOGS)"

# extract product ids
plutil_extract Products "$(basename $DEFAULT_SUCATALOGS)" products.plist

# extract product ids
products=( $( defaults read $TMP_DIR/products.plist | cut -d= -f1 | grep -e "-" | tr -d '"' | sort -n ) )

# # find valids ids
# mkdir -p valids && rm -Rf valids/*
# for id in "${products[@]}"
# do
#     if [[ $(plutil_get_value $id.ExtendedMetaInfo.InstallAssistantPackageIdentifiers.OSInstall products.plist) != "__property_not_found__" ]]
#     then
#         plutil_extract $id products.plist valids/$id.plist
#     fi
# done

# get build info
# mkdir -p downloads && rm -Rf downloads/*
cd downloads || exit 1
for z in ../valids/*.plist
do
    id=$(basename "$z") && id="${id%.*}"
    # mkdir -p $id && rm -Rf ${id:?}/*

    # get InstallAssistantAuto.smd file
    serverMetadataUrl="$(get_plist_property $z ":ServerMetadataURL")"

    # get distibution
    distributions="$(get_plist_property $z ":Distributions:English")"

    cd $id || exit 1
    download $serverMetadataUrl
    download $distributions


    # get installer version
    version="$(get_plist_property InstallAssistantAuto.smd ":CFBundleShortVersionString")"

    # get installer title
    if [[ $(get_plist_property InstallAssistantAuto.smd ":localization:English:title") != "__property_not_found__" ]]
    then
        title="$(get_plist_property InstallAssistantAuto.smd ":localization:English:title")"
    elif [[ $(get_plist_property InstallAssistantAuto.smd ":localization:en:title") != "__property_not_found__" ]]; then
        title="$(get_plist_property InstallAssistantAuto.smd ":localization:en:title")"
    else
        title='macOS installer'
    fi

    # get post date
    postDate="$(get_plist_property ../$z ":PostDate")"
    postDate=$(date -j -f "%a %b %d %H:%M:%S %Z %Y" "$postDate" +"%Y-%m-%d")

    # get build
    while read_dom; do
        builds=($(parse_dom) "${builds[@]}")
    done < "$(basename $distributions)"

    _versions=("$version" "${_versions[@]}")
    _titles=("$title" "${_titles[@]}")
    _ids=("$id" "${_ids[@]}")
    _date=("$postDate" "${_date[@]}")
    _dist_file=("$distributions" "${_dist_file[@]}")
    _build=("${builds[1]}" "${_build[@]}")

    cd ..

done

cd ..

# build options menu
for (( i = 0; i < ${#_ids[@]}; i++ )); do
    printf -v str '\t%s\t%s\t\t%s\t\t%s\t%s' "${_ids[$i]}" "${_versions[$i]}" "${_build[$i]}" "${_date[$i]}" "${_titles[$i]}"
    options=("$str" "${options[@]}")
done

printf '#\tProductID\tVersion\t\tBuild\t\tPost Date\tTitle\n'

prompt="Please select version:"
PS3="$prompt "
select targetVersion in "${options[@]}"; do
    if (( REPLY == 1 + ${#options[@]} )) ; then
        exit

    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        break

    else
        echo "Invalid option. Try another one."
    fi
done

# find array index of the choosen build
my_array=("${_ids[@]}")
value="$( echo $targetVersion | cut -d' ' -f1 )"

for i in "${!my_array[@]}"; do
    if [[ "${my_array[$i]}" = "${value}" ]]; then
        idx="${i}";
    fi
done

# count Packages array elements
c=$(count_plist_array_elements Packages valids/${_ids[$idx]}.plist)

# get links
for (( i = 0; i < $c; i++ )); do
    urls=("$(get_plist_property valids/${_ids[$idx]}.plist ":Packages:$i:URL")" "${urls[@]}")
    if [[ $(get_plist_property valids/${_ids[$idx]}.plist ":Packages:$i:MetadataURL") != "__property_not_found__" ]]; then
        urls=("$(get_plist_property valids/${_ids[$idx]}.plist ":Packages:$i:MetadataURL")" "${urls[@]}")
    fi
done

# download build
cd downloads/${_ids[$idx]} || exit 1

# for l in "${urls[@]}"
# do
#     download "$l"
# done

cd ../.. || exit 1

# # clean
rm -Rf *.sparseimage

# generate a name for the sparseimage
imgName="Install_macOS_${_versions[$idx]}-${_build[$idx]}.sparseimage"

# Make a sparse disk image we can install a product to
/usr/bin/hdiutil create -size 8g -fs HFS+ -volname "$imgName" -type SPARSE -plist $TMP_DIR/$imgName > sparse_img.plist
dmgPath=$(get_plist_property sparse_img.plist ":0")

# Attempts to mount the dmg at dmgpath and returns first mountpoint
/usr/bin/hdiutil attach "$dmgPath" -mountRandom $TMP_DIR -nobrowse -plist -owners on > mount_point.plist
mountPoint=$(get_plist_property mount_point.plist ":system-entities:0:mount-point")

# build the installer
sudo /usr/sbin/installer -pkg downloads/${_ids[$idx]}/${_ids[$idx]}.*.dist -target "$mountPoint"

# Returns path to newly-created compressed r/o disk image containing Install macOS.app
# echo "$SCRIPT_DIR/${imgName%.*}".dmg
installerApp=$(echo "$mountPoint"/Applications/*.app)
sudo /usr/bin/hdiutil create -fs HFS+ -srcfolder "$installerApp" "$SCRIPT_DIR/${imgName%.*}".dmg

# unmount dmg
sudo /usr/bin/hdiutil detach "$mountPoint" -force

# EOF
