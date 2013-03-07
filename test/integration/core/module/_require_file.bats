#!/usr/bin/env bats

load lib
load core::module
load core::environment
load commands
load main::environment.mock

setup() {
    MODULES_PATH="$BATS_TEST_DIRNAME/_require_file"
}

@test "The parameters has not been specified" {
    run core::module::_require_file

    [ "$status" -eq 1 ]
}

@test "The nonexistent module has been specified" {
    run core::module::_require_file "nonexistent_module"

    [ "$status" -eq 1 ]
}

@test "The file has not been specified" {
    run core::module::_require_file "complete_module"

    [ "$status" -eq 1 ]
}

@test "The not standard file has been specified" {
    run core::module::_require_file "not_standard_file"

    [ "$status" -eq 1 ]
}

@test "The dependencies file has been specified for complete module" {
    run core::module::_require_file "complete_module" "$DEPS_FILE"

    [ "$status" -eq 1 ]
}

@test "The packages file has been specified for complete module" {
    run core::module::_require_file "complete_module" "$PACKS_FILE"

    [ "$status" -eq 1 ]
}

@test "The options file has been specified for complete module" {
    run core::module::_require_file "complete_module" "$OPTS_FILE"

    [ "$status" -eq 1 ]
}

@test "The not_standard_command command has been specified for module" {
    run core::module::_require_file "module_with_not_standard_file" "not_standard_file.sh"

    [ "$status" -eq 2 ]
}
