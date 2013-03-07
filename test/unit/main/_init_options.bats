#!/usr/bin/env bats

load main.lib
load throw.mock
load core::module::require_opts.mock

require() {
    MODULE_OPTS[a]=false
}

@test "The options has not been specified" {
    run main::_init_options

    [ "$status" -eq 0 ]
}

@test "The option --conf has been specified" {
    main::_init_options_by_conf() {
        exit 1
    }

    run main::_init_options "--conf" "path"

    [ "$status" -eq 1 ]
}

@test "Some options has been specified" {
    MODULES=( module )
    SHORT_OPTS="a"

    main::_init_options "-a"

    [ "${#MODULE_OPTS[@]}" -eq 1 ]
}

@test "The option --conf and other has been specified" {
    MODULES=( module )
    SHORT_OPTS="a"

    main::_init_options "--conf" "path" "-a"

    [[ "${MODULE_OPTS[a]}" == false ]]
}
