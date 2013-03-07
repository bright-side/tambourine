#!/usr/bin/env bats

load main.lib
load core::module::require_opts.mock

@test "The parameters has not been specified" {
    run main::_init_options_by_args

    [ "$status" -eq 0 ]
}

@test "Short option not demanding an argument is not set" {
    MODULES=( module )
    SHORT_OPTS="a"

    main::_init_options_by_args

    [[ "${MODULE_OPTS[a]}" == "" ]]
}

@test "Short option not demanding an argument is set" {
    MODULES=( module )
    SHORT_OPTS="a"

    main::_init_options_by_args "-a"

    [[ "${MODULE_OPTS[a]}" == "true" ]]
}

@test "Short option demanding an argument is set without an argument" {
    MODULES=( module )
    SHORT_OPTS="a:"

    main::_init_options_by_args "-a"

    [[ "${MODULE_OPTS[a]}" == "" ]]
}

@test "Short option demanding an argument is set with an argument" {
    MODULES=( module )
    SHORT_OPTS="a:"

    main::_init_options_by_args "-avalue"

    [[ "${MODULE_OPTS[a]}" == "value" ]]
}

@test "Short option with an optional argument is set without an argument" {
    MODULES=( module )
    SHORT_OPTS="a::"

    main::_init_options_by_args "-a"

    [[ "${MODULE_OPTS[a]}" == "true" ]]
}

@test "Short option with an optional argument is set with an argument" {
    MODULES=( module )
    SHORT_OPTS="a::"

    main::_init_options_by_args "-avalue"

    [[ "${MODULE_OPTS[a]}" == "value" ]]
}

@test "Several known short options are specified" {
    MODULES=( module )
    SHORT_OPTS="abc"

    main::_init_options_by_args "-a" "-b" "-c"

    [[ "${MODULE_OPTS[a]}" == "true" ]]
    [[ "${MODULE_OPTS[b]}" == "true" ]]
    [[ "${MODULE_OPTS[c]}" == "true" ]]
}

@test "A short known option is set among unknown options" {
    MODULES=( module )
    SHORT_OPTS="a"

    main::_init_options_by_args "after" "-a" "before"

    [[ "${MODULE_OPTS[a]}" == "true" ]]
}

@test "Long option not demanding an argument is not set" {
    MODULES=( module )
    LONG_OPTS="long-a"

    main::_init_options_by_args

    [[ "${MODULE_OPTS[long-a]}" == "" ]]
}

@test "Long option not demanding an argument is set" {
    MODULES=( module )
    LONG_OPTS="long-a"

    main::_init_options_by_args "--long-a"

    [[ "${MODULE_OPTS[long-a]}" == "true" ]]
}

@test "Long option demanding an argument is set without an argument" {
    MODULES=( module )
    LONG_OPTS="long-a:"

    run main::_init_options_by_args "--long-a"

    [[ "${MODULE_OPTS[long-a]}" == "" ]]
}

@test "Long option demanding an argument is set with an argument" {
    MODULES=( module )
    LONG_OPTS="long-a:"

    main::_init_options_by_args "--long-a" "value"

    [[ "${MODULE_OPTS[long-a]}" == "value" ]]
}

@test "Long option with an optional argument is set without an argument" {
    MODULES=( module )
    LONG_OPTS="long-a::"

    main::_init_options_by_args "--long-a"

    [[ "${MODULE_OPTS[long-a]}" == "true" ]]
}

@test "Long option with an optional argument is set with an argument" {
    MODULES=( module )
    LONG_OPTS="long-a::"

    main::_init_options_by_args "--long-a=value"

    [[ "${MODULE_OPTS[long-a]}" == "value" ]]
}

@test "Several known long options are specified" {
    MODULES=( module )
    LONG_OPTS="long-a long-b long-c"

    main::_init_options_by_args "--long-a" "--long-b" "--long-c"

    [[ "${MODULE_OPTS[long-a]}" == "true" ]]
    [[ "${MODULE_OPTS[long-b]}" == "true" ]]
    [[ "${MODULE_OPTS[long-c]}" == "true" ]]
}
