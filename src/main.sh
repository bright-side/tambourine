#!/bin/bash

PWD=`pwd`
SHELL_EXTENSION="sh"
MODULES_PATH="$PWD/modules"

main() {
    local lib_path="$PWD/main.lib.$SHELL_EXTENSION"

    if [ ! -f "$lib_path" ]; then
        exit 1
    fi
    . "$lib_path"

    main::_build
    main::_check_uid
}; main $@