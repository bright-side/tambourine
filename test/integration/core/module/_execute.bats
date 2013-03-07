#!/usr/bin/env bats

load lib
load core::module
load commands
load main::environment.mock

setup() {
    MODULES_PATH="$BATS_TEST_DIRNAME/_execute"
}

@test "The parameters has not been specified" {
    run core::module::_execute

    [ "$status" -eq 1 ]
}

@test "The nonexistent module has been specified" {
    run core::module::_execute "nonexistent_module"

    [ "$status" -eq 1 ]
}

@test "The command has not been specified" {
    run core::module::_execute "complete_module"

    [ "$status" -eq 1 ]
}

@test "The not standard command has been specified" {
    run core::module::_execute "complete_module" "not_standard_command"

    [ "$status" -eq 1 ]
}

@test "The install command has been specified for complete module" {
    run core::module::_execute "complete_module" "install"

    [ "$status" -eq 0 ]
}

@test "The uninstall command has been specified for complete module" {
    run core::module::_execute "complete_module" "uninstall"

    [ "$status" -eq 0 ]
}

@test "The check command has been specified for complete module" {
    run core::module::_execute "complete_module" "check"

    [ "$status" -eq 0 ]
}

@test "The not_standard_command command has been specified for module" {
    run core::module::_execute "module_with_not_standard_command" "not_standard_command"

    [ "$status" -eq 2 ]
}
