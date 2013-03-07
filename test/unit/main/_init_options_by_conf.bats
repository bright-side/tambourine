#!/usr/bin/env bats

load main.lib
load throw.mock
load require.mock

require() {
    if [[ "$BATS_TEST_DIRNAME/_init_options_by_conf/conf.sh" == "$1" ]] && [ ! -z "$1" ]; then
        CONF=TRUE
    else
        exit 1
    fi
}

@test "The parameters has not been specified" {
    run main::_init_options_by_conf

    [ "$status" -eq 1 ]
}

@test "The option --conf has not been specified" {
    run main::_init_options_by_conf "--other"

    [ "$status" -eq 1 ]
}

@test "The path to config file is not specified" {
    run main::_init_options_by_conf "--conf"

    [ "$status" -eq 1 ]
}

@test "The path to config file is specified (space style)" {
    main::_init_options_by_conf "--conf" "$BATS_TEST_DIRNAME/_init_options_by_conf/conf.sh"

    [[ "$CONF" == "TRUE" ]]
}

@test "The path to config file is specified (= style)" {
    main::_init_options_by_conf "--conf=$BATS_TEST_DIRNAME/_init_options_by_conf/conf.sh"

    [[ "$CONF" == "TRUE" ]]
}

@test "The list of arguments contains trash besides the path to config file" {
    main::_init_options_by_conf "command" "--conf" "$BATS_TEST_DIRNAME/_init_options_by_conf/conf.sh" "--other-arg1" "--other-arg2" "othet value"

    [[ "$CONF" == "TRUE" ]]
}
