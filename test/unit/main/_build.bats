#!/usr/bin/env bats

load main.lib
load main::environment.mock
load throw.mock
load require.mock
load core::module::check_completeness.mock

@test "The library file doesn't exists" {
    PWD="$BATS_TEST_DIRNAME/_build_has_not_lib"

    run main::_build

    [ "$status" -eq 1 ]
    [[ "$output" == "Internal error: the file \"$PWD/lib.$SHELL_EXTENSION\" does not exist!" ]]
}

@test "The library file exists" {
    PWD="$BATS_TEST_DIRNAME/_build_has_lib"

    run main::_build

    [ "$status" -eq 0 ]
}

@test "The pwd directory doesn't exists" {
    PWD="$BATS_TEST_DIRNAME/nonexistent_dir"

    run main::_build

    [ "$status" -eq 1 ]
}
