#!/usr/bin/env bats

load lib
load core::module
load commands
load main::environment.mock

setup() {
    MODULES_PATH="$BATS_TEST_DIRNAME/check_completeness"
}

@test "The parameters has not been specified" {
    run core::module::check_completeness

    [ "$status" -eq 1 ]
}

@test "The nonexistent module has been specified" {
    run core::module::check_completeness "nonexistent_module"

    [ "$status" -eq 1 ]
}

@test "The empty module has been specified" {
    run core::module::check_completeness "empty_module"

    [ "$status" -eq 1 ]
}

@test "The module without dependencies has been specified" {
    run core::module::check_completeness "module_without_deps"

    [ "$status" -eq 1 ]
}

@test "The module without packages has been specified" {
    run core::module::check_completeness "module_without_packs"

    [ "$status" -eq 1 ]
}

@test "The module without options has been specified" {
    run core::module::check_completeness "module_without_opts"

    [ "$status" -eq 1 ]
}

@test "The module without install command has been specified" {
    run core::module::check_completeness "module_without_install"

    [ "$status" -eq 1 ]
}

@test "The module without uninstall command has been specified" {
    run core::module::check_completeness "module_without_uninstall"

    [ "$status" -eq 1 ]
}

@test "The module without check command has been specified" {
    run core::module::check_completeness "module_without_check"

    [ "$status" -eq 1 ]
}
