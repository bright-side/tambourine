#!/usr/bin/env bats

load lib

setup() {
    default_error_message="Oops... An internal error has occurred, spank us!"
    user_error_message="user error message"
}

@test "Default error message" {
    run throw

    [ "$status" -eq 1 ]
    [[ "$output" == "$default_error_message" ]]
}

@test "Error message has been specified" {
    run throw "$user_error_message"

    [ "$status" -eq 1 ]
    [[ "$output" == "$user_error_message" ]]
}
