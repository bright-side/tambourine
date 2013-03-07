#!/usr/bin/env bats

load main.lib

setup() {
    declare -Ag MODULES_STATE
}

@test "The list of modules is empty" {
    MODULES=()

    run main::_report_modules_states

    [[ "$output" == "" ]]
}

@test "The specified module is installed" {
    MODULES=( module_1 )
    MODULES_STATE[module_1]="INSTALLED"

    run main::_report_modules_states

    [[ "$output" == "The module \"module_1\" is installed." ]]
}

@test "The specified module is installed with other options" {
    MODULES=( module_1 )
    MODULES_STATE[module_1]="INSTALLED_WITH_OTHER_OPTIONS"

    run main::_report_modules_states

    [[ "$output" == "The module \"module_1\" is installed, but with other options." ]]
}

@test "The specified module is not installed" {
    MODULES=( module_1 )
    MODULES_STATE[module_1]="NOT_INSTALLED"

    run main::_report_modules_states

    [[ "$output" == "The module \"module_1\" is not installed." ]]
}

@test "The specified module state undefined" {
    MODULES=( module_1 )
    MODULES_STATE[module_1]=""

    run main::_report_modules_states

    [[ "$output" == "" ]]
}
