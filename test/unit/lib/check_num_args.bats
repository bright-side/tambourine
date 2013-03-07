#!/usr/bin/env bats

load lib

setup() {
    default_error_message="Internal error: the function check_num_args() expecting 3 required parameters!"
    function_name="function_name"
}

@test "The parameters has not been specified" {
    run check_num_args

    [ "$status" -eq 1 ]
    [[ "$output" == "$default_error_message" ]]
}

@test "The required number parameter is an empty string" {
    required_number=""
    current_number=1

    run check_num_args $required_number $current_number "$function_name"

    [ "$status" -eq 1 ]
    [[ "$output" == "$default_error_message" ]]
}

@test "The current number parameter is an empty string" {
    required_number=1
    current_number=""

    run check_num_args $required_number $current_number "$function_name"

    [ "$status" -eq 1 ]
    [[ "$output" == "$default_error_message" ]]
}

@test "Required number parameter only" {
    required_number=1

    run check_num_args $required_number

    [ "$status" -eq 1 ]
    [[ "$output" == "$default_error_message" ]]
}

@test "Required & current number without function name" {
    required_number=1
    current_number=1

    run check_num_args $required_number $current_number

    [ "$status" -eq 1 ]
    [[ "$output" == "$default_error_message" ]]
}

@test "The required number is more than the current number" {
    required_number=2
    current_number=1

    run check_num_args $required_number $current_number "$function_name"

    [ "$status" -eq 1 ]
    [[ "$output" == "Internal error: the function $function_name() expecting at least 2 required parameters!" ]]
}

@test "The required number is equal to the current number" {
    required_number=2
    current_number=2

    run check_num_args $required_number $current_number "$function_name"

    [ "$status" -eq 0 ]
}

@test "The current number is more than the required number" {
    required_number=2
    current_number=3

    run check_num_args $required_number $current_number "$function_name"

    [ "$status" -eq 0 ]
}
