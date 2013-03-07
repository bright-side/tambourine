#!/usr/bin/env bats

load main.lib
load throw.mock

setup() {
    STANDARD_COMMANDS=( steal fuck kill )
    COMMAND=""
}

@test "The argument list is an empty string" {
    run main::_init_command ""

    [ "$status" -eq 1 ]
}

@test "The list of standard commands is an empty" {
    STANDARD_COMMANDS=()

    run main::_init_command "steal"

    [ "$status" -eq 1 ]
}

@test "The specified list of arguments doesn't contain standard commands" {
    run main::_init_command "drink imbibe tipple bib sot"

    [ "$status" -eq 1 ]
}

@test "The specified command is standard" {
    main::_init_command "steal"

    [[ "$COMMAND" == "steal" ]]
}

@test "The specified list of arguments contains a standard command" {
    main::_init_command "steal" "tipple" "bib" "sot"

    [[ "$COMMAND" == "steal" ]]
}

@test "The specified list of arguments contains standard & not standard commands" {
    main::_init_command "steal" "gum"

    [[ "$COMMAND" == "steal" ]]
}

@test "The specified list of arguments contains only standard commands" {
    main::_init_command "steal" "fuck" "kill"

    [[ "$COMMAND" == "steal" ]]
}
