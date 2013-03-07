#!/usr/bin/env bats

load main.lib
load throw.mock

setup() {
    declare -ag MODULES
    declare -Ag MODULES_STATE
}

@test "The list of modules is empty" {
    MODULES=()

    main::_exclude_installed_modules

    [[ "${MODULES[@]}" == "" ]]
}

@test "The list of modules consists of only one installed module" {
    MODULES=( module_1 )
    MODULES_STATE[module_1]=INSTALLED

    main::_exclude_installed_modules

    [[ "${MODULES[@]}" == "" ]]
}

@test "The list of modules consists of only one not installed module" {
    MODULES=( module_1 )
    MODULES_STATE[module_1]=NOT_INSTALLED

    main::_exclude_installed_modules

    [[ "${MODULES[@]}" == "module_1" ]]
}

@test "The list of modules consists of installed modules" {
    MODULES=( module_1 module_2 module_3 )
        MODULES_STATE[module_1]=INSTALLED
        MODULES_STATE[module_2]=INSTALLED
        MODULES_STATE[module_3]=INSTALLED

    main::_exclude_installed_modules

    [[ "${MODULES[@]}" == "" ]]
}

@test "The list of modules consists of not installed modules" {
    MODULES=( module_1 )
    MODULES_STATE[module_1]=NOT_INSTALLED
    MODULES_STATE[module_2]=NOT_INSTALLED
    MODULES_STATE[module_3]=NOT_INSTALLED

    main::_exclude_installed_modules

    [[ "${MODULES[@]}" == "module_1" ]]
}

@test "The list of modules consists of installed & not installed modules" {
    MODULES=( module_1 module_2 module_3 )
    MODULES_STATE[module_1]=NOT_INSTALLED
    MODULES_STATE[module_2]=INSTALLED
    MODULES_STATE[module_3]=NOT_INSTALLED

    main::_exclude_installed_modules

    [[ "${MODULES[@]}" == "module_1 module_3" ]]
}
