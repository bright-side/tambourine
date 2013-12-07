#!/usr/bin/env bats

load lib

setup() {
	error_message="Internal error: the function get_module_opts_var() expecting at least 1 required parameters!"
    module_name="some_module"
}

@test "Module name has not been specified" {
    run get_module_opts_var

    [ "$status" -eq 1 ]
    [[ "$output" = "$error_message" ]]
}

@test "Module name has been specified" {
    get_module_opts_var "$module_name"

    [ $? -eq 0 ]
    [[ $MODULE_OPTS_VAR = "SOME_MODULE_OPTS" ]]
}
