#!/usr/bin/env bats

load main.lib
load throw.mock

setup() {
    STANDARD_MODULES=( adamantium_skeleton eye_blaster gum )
    MODULES=()
}

@test "The list of arguments is an empty string" {
    run main::_init_modules ""

    [ "$status" -eq 1 ]
}

@test "The list of standard commands is empty" {
    STANDARD_MODULES=()

    run main::_init_modules "teddy"

    [ "$status" -eq 1 ]
}

@test "The specified list of arguments doesn't contain standard modules" {
    run main::_init_modules "teddy bunny pussy"

    [ "$status" -eq 1 ]
}

@test "The specified module is standard" {
    main::_init_modules "gum"

    [[ "${MODULES[@]}" == "gum" ]]
}

@test "The specified list of arguments contains a standard module" {
    main::_init_modules "teddy" "gum" "bunny" "pussy"

    [[ "${MODULES[@]}" == "gum" ]]
}

@test "The specified list of arguments contains standard & not standard commands" {
    main::_init_modules "teddy" "gum"

    [[ "${MODULES[@]}" == "gum" ]]
}

@test "The specified list of arguments contains only standard modules" {
    main::_init_modules "adamantium_skeleton" "eye_blaster" "gum"

    [[ "${MODULES[@]}" == "adamantium_skeleton eye_blaster gum" ]]
}
