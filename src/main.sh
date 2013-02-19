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

    main::_init_command $@
    main::_init_modules $@
    main::_init_options $@

    if [[ "install" == "$COMMAND" ]]; then
        main::_extend_modules_by_deps

        for module in "${MODULES[@]}"; do
            core::module::check "$module"
        done
    fi

    for module in "${MODULES[@]}"; do
        core::module::_execute "$module" "$COMMAND"
    done
}; main $@