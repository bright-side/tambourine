#!/usr/bin/env bats

load lib
load core::environment
load core::module
load main.lib

setup() {
    SHELL_EXTENSION="sh"
    PWD="$BATS_TEST_DIRNAME/_build/complete_root"
    MODULES_PATH="$BATS_TEST_DIRNAME/_build/complete_modules"
}

@test "Build of complete root & modules" {
    run main::_build

    [ "$status" -eq 0 ]
}

@test "Build of broken root without library" {
    PWD="$BATS_TEST_DIRNAME/_build/broken_root_without_lib"

    run main::_build

    [ "$status" -eq 1 ]
}

@test "Build of broken root without standard commands" {
    PWD="$BATS_TEST_DIRNAME/_build/broken_root_without_commands"

    run main::_build

    [ "$status" -eq 1 ]
}

@test "Build of broken root without standard modules" {
    PWD="$BATS_TEST_DIRNAME/_build/broken_root_without_modules"

    run main::_build

    [ "$status" -eq 1 ]
}

@test "Build of broken root without standard core" {
    PWD="$BATS_TEST_DIRNAME/_build/broken_root_without_core"

    run main::_build

    [ "$status" -eq 1 ]
}

@test "Build of broken modules" {
    PWD="$BATS_TEST_DIRNAME/_build/broken_modules_root"
    MODULES_PATH="$BATS_TEST_DIRNAME/_build/broken_modules"

    run main::_build

    [ "$status" -eq 1 ]
}
