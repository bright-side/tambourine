#!/bin/bash

core::module::check_completeness() {
    check_num_args 1 $# $FUNCNAME

    local module_dir="$MODULES_PATH/$1"
    check_dir "$module_dir" "Error: the module \"$1\" does not exist!"

    check_file "$module_dir/$DEPS_FILE" "Error: the dependencies file of the module \"$1\" does not exist!"
    check_file "$module_dir/$PACKS_FILE" "Error: the packages file of the module \"$1\" does not exist!"
    check_file "$module_dir/$OPTS_FILE" "Error: the options file of the module \"$1\" does not exist!"

    for command in "${STANDARD_COMMANDS[@]}"; do
        check_file "$module_dir/$command.$SHELL_EXTENSION" "Error: the $command file of the module \"$1\" does not exist!"
    done
}

core::module::_require_file() {
    check_num_args 2 $# $FUNCNAME

    local path="$MODULES_PATH/$1/$2"

    case "$2" in
        "$DEPS_FILE" )
            local filetype="dependencies"
            ;;
        "$PACKS_FILE" )
            local filetype="packages"
            ;;
        "$OPTS_FILE" )
            local filetype="options"
            ;;
        esac

    require "$path" "Error: the $filetype file of the module \"$1\" does not exist!"

    if [ -z $filetype ]; then
        echo "Warning: type of the required file \"$path\" of the module \"$1\" is not standard!"
        return 2
    fi
}

core::module::_execute() {
    check_num_args 2 $# $FUNCNAME

    require "$MODULES_PATH/$1/$2.$SHELL_EXTENSION" "Error: the $2 file of the module \"$1\" does not exist!"

    if [[ ! "${STANDARD_COMMANDS[@]}" =~ "$2" ]]; then
        echo "Warning: the command \"$2\" of the module \"$1\" is not standard!"
        return 2
    fi
}

core::module::require_deps() {
    check_num_args 1 $# $FUNCNAME

    core::module::_require_file "$1" "$DEPS_FILE"
}

core::module::require_packs() {
    check_num_args 1 $# $FUNCNAME

    core::module::_require_file "$1" "$PACKS_FILE"
}

core::module::require_opts() {
    check_num_args 1 $# $FUNCNAME

    core::module::_require_file "$1" "$OPTS_FILE"
}

core::module::install() {
    check_num_args 1 $# $FUNCNAME

    core::module::_execute "$1" "install"
}

core::module::uninstall() {
    check_num_args 1 $# $FUNCNAME

    core::module::_execute "$1" "remove"
}

core::module::check() {
    check_num_args 1 $# $FUNCNAME

    core::module::_execute "$1" "check"
}