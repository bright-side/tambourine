#!/usr/bin/env bats

load main.lib
load confirm.mock

setup() {
    declare -Ag MODULES_STATE
}

@test "The list modules is empty" {
    MODULES=()

    run main::_report_modules_need_reinstall

    [[ "$output" == "" ]]
}

@test "The list of modules consists of installed modules" {
    MODULES=( module_1 module_2 module_3 )
    MODULES_STATE[module_1]="INSTALLED"
    MODULES_STATE[module_2]="INSTALLED"
    MODULES_STATE[module_3]="INSTALLED"

    run main::_report_modules_need_reinstall

    [[ "$output" == "" ]]
}

@test "The list of modules consists of not installed modules" {
    MODULES=( module_1 module_2 module_3 )
    MODULES_STATE[module_1]="NOT_INSTALLED"
    MODULES_STATE[module_2]="NOT_INSTALLED"
    MODULES_STATE[module_3]="NOT_INSTALLED"

    run main::_report_modules_need_reinstall

    [[ "$output" == "" ]]
}

@test "The list of modules consists of installed & not installed modules" {
    MODULES=( module_1 module_2 module_3 )
    MODULES_STATE[module_1]="INSTALLED"
    MODULES_STATE[module_2]="NOT_INSTALLED"
    MODULES_STATE[module_3]="INSTALLED_WITH_OTHER_OPTIONS"

    run main::_report_modules_need_reinstall

    [[ "${lines[1]}" == " * module_3" ]]
}

@test "The list of modules consists of installed with other options modules" {
    MODULES=( module_1 module_2 module_3 )
    MODULES_STATE[module_1]="INSTALLED_WITH_OTHER_OPTIONS"
    MODULES_STATE[module_2]="INSTALLED_WITH_OTHER_OPTIONS"
    MODULES_STATE[module_3]="INSTALLED_WITH_OTHER_OPTIONS"

    run main::_report_modules_need_reinstall

    [[ "${lines[1]}" == " * module_1" ]]
    [[ "${lines[2]}" == " * module_2" ]]
    [[ "${lines[3]}" == " * module_3" ]]
}
