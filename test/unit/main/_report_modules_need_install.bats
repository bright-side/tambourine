#!/usr/bin/env bats

load main.lib
load confirm.mock

setup() {
    declare -Ag MODULES_STATE
}

@test "The list modules is empty" {
    MODULES=()
    INITED_MODULES=()

    run main::_report_modules_need_install

    [[ "$output" == "" ]]
}

@test "The list of initialized modules is empty" {
    MODULES=( module_1 module_2 module_3 )
    INITED_MODULES=()

    run main::_report_modules_need_install

    [[ "$output" == "" ]]
}

@test "The list of modules consists of installed modules, all modules has been specified by user" {
    MODULES=( module_1 module_2 module_3 )
    INITED_MODULES=( module_1 module_2 module_3 )

    MODULES_STATE[module_1]="INSTALLED"
    MODULES_STATE[module_2]="INSTALLED"
    MODULES_STATE[module_3]="INSTALLED"

    run main::_report_modules_need_install

    [[ "$output" == "" ]]
}

@test "The list of modules consists of not installed modules, all modules has been specified by user" {
    MODULES=( module_1 module_2 module_3 )
    INITED_MODULES=( module_1 module_2 module_3 )

    MODULES_STATE[module_1]="NOT_INSTALLED"
    MODULES_STATE[module_2]="NOT_INSTALLED"
    MODULES_STATE[module_3]="NOT_INSTALLED"

    run main::_report_modules_need_install

    [[ "$output" == "" ]]
}

@test "The list of modules consists of not installed modules, part of modules has not been specified by user" {
    MODULES=( module_1 module_2 module_3 )
    INITED_MODULES=( module_1 module_3 )

    MODULES_STATE[module_1]="NOT_INSTALLED"
    MODULES_STATE[module_2]="NOT_INSTALLED"
    MODULES_STATE[module_3]="NOT_INSTALLED"

    run main::_report_modules_need_install

    [[ "${lines[1]}" == " * module_2" ]]
}

@test "The list of modules consists of installed & not installed modules, part of modules has not been specified by user" {
    MODULES=( module_1 module_2 module_3 )
    INITED_MODULES=( module_1 module_3 )

    MODULES_STATE[module_1]="INSTALLED"
    MODULES_STATE[module_2]="NOT_INSTALLED"
    MODULES_STATE[module_3]="INSTALLED"

    run main::_report_modules_need_install

    [[ "${lines[1]}" == " * module_2" ]]
}
