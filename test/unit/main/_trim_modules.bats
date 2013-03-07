#!/usr/bin/env bats

load main.lib

@test "The list of modules is empty" {
    MODULES=()

    main::_trim_modules

    [[ "${MODULES[@]}" == "" ]]
}

@test "The list of modules contain only one module" {
    MODULES=( 1 )

    main::_trim_modules

    [[ "${MODULES[@]}" == "1" ]]
}

@test "The list of modules contains duplicate of only one module" {
    MODULES=( 2 2 2 2 )

    main::_trim_modules

    [[ "${MODULES[@]}" == "2" ]]
}

@test "The list of modules contains repetitions" {
    MODULES=( 1 1 1 2 3 3 3 )

    main::_trim_modules

    [[ "${MODULES[@]}" == "1 2 3" ]]
}

@test "The list of modules doesn't contain repetitions" {
    MODULES=( 1 2 3 4 5 6 7 8 9 10 )

    main::_trim_modules

    [[ "${MODULES[@]}" == "1 2 3 4 5 6 7 8 9 10" ]]
}

