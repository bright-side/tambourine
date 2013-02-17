#!/bin/bash

core::module::check_completeness() {
    check_num_args 1 $# $FUNCNAME

    local module_dir="$MODULES_PATH/$1"
    check_dir "$module_dir"

    check_file "$module_dir/$DEPS_FILE"
    check_file "$module_dir/$PACKS_FILE"
    check_file "$module_dir/$OPTS_FILE"

    for command in "${STANDARD_COMMANDS[@]}"; do
        check_file "$module_dir/$command.$SHELL_EXTENSION"
    done
}