#!/bin/bash

PWD=`pwd`
SHELL_EXTENSION="sh"
MODULES_PATH="$PWD/modules"

main() {
    declare -A MODULES_STATE

    local lib_path="$PWD/main.lib.$SHELL_EXTENSION"

    if [ ! -f "$lib_path" ]; then
        echo "Internal error: the file \"$lib_path\" does not exist!"
        exit 1
    fi
    . "$lib_path"

    main::_build
    main::_check_uid

    # Объявления массивов опций для модулей
    for module in "${STANDARD_MODULES[@]}"; do
        get_module_opts_var $module
        declare -A "$MODULE_OPTS_VAR"
    done

    main::_init_command $@
    main::_init_modules $@
    main::_init_options $@

    ORIGINAL_MODULES=("$@")

    if [[ "install" == "$COMMAND" ]]; then
        echo "Preparing to install modules..."

        main::_extend_modules_by_deps

        for module in "${MODULES[@]}"; do
            core::module::check "$module"
        done

        main::_exclude_installed_modules

        main::_report_modules_need_install
        main::_report_modules_need_reinstall
    fi

    if [[ "uninstall" == "$COMMAND" ]]; then
        echo "Preparing to uninstall modules..."

        main::_report_can_break_modules
    fi

    for module in "${MODULES[@]}"; do
        core::module::_execute "$module" "$COMMAND"
    done

    if [[ "check" == "$COMMAND" ]]; then
        main::_report_modules_states
    fi
}; main $@