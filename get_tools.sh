#!/usr/bin/env bash

# set -x

# start in folder script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

# update tools to latest
if [ -e ./tools/.git ]; then
    echo "updating tools..."
    cd ./tools && git pull
    echo
    cd ..
elif [[ ! -d ./tools ]]; then
    git clone https://github.com/bombons/hack_tools.git tools
    echo
fi
