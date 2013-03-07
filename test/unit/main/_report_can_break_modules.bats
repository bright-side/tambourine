#!/usr/bin/env bats

load main.lib
load confirm.mock

setup() {
    declare -Ag MODULES_STATE
}

core::module::check() {
    return 0
}

@test "The list of modules is empty" {
    MODULES=()

    run main::_report_can_break_modules

    [[ "$output" == "" ]]
}

@test "The list of modules consist of independent modules" {
    core::module::require_deps() {
        DEPS=()
    }

    MODULES=( module_1 )
    STANDARD_MODULES=( module_1 module_2 module_3 )

    run main::_report_can_break_modules

    [[ "$output" == "" ]]
}

@test "Several modules depend on the removed module" {
    core::module::require_deps() {
        case "$1" in
            module_1 )
                DEPS=()
                ;;
            module_2 )
                DEPS=( module_1 )
                ;;
            module_3 )
                DEPS=( module_1 )
                ;;
        esac
    }

    MODULES=( module_1 )
    STANDARD_MODULES=( module_1 module_2 module_3 )

    run main::_report_can_break_modules

    [[ "${lines[1]}" == " * module_2" ]]
    [[ "${lines[2]}" == " * module_3" ]]
}

@test "The modules depends on the removed module the chain" {
    core::module::require_deps() {
        case "$1" in
            module_1 )
                DEPS=()
                ;;
            module_2 )
                DEPS=( module_1 )
                ;;
            module_3 )
                DEPS=( module_2 )
                ;;
            module_4 )
                DEPS=( module_3 )
                ;;
            module_5 )
                DEPS=( module_4 )
                ;;
        esac
    }

    MODULES=( module_1 )
    STANDARD_MODULES=( module_1 module_2 module_3 module_4 module_5 )

    run main::_report_can_break_modules

    [[ "${lines[1]}" == " * module_2" ]]
    [[ "${lines[2]}" == " * module_3" ]]
    [[ "${lines[3]}" == " * module_4" ]]
    [[ "${lines[4]}" == " * module_5" ]]
}
