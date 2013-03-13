#!/bin/bash

throw() {
    echo "${1-Oops... An internal error has occurred, spank us!}"
    exit 1
}

check_num_args() {
    if [ $# -lt 3 ]; then
        throw "Internal error: the function $FUNCNAME() expecting 3 required parameters!"
    fi

    if [ $1 -gt $2 ]; then
        throw "Internal error: the function $3() expecting at least $1 required parameters!"
    fi
}

check_dir() {
    check_num_args 1 $# $FUNCNAME

    if [ ! -d "$1" ]; then
        throw "${2-Internal error: the directory \"$1\" does not exist!}"
    fi
}

check_file() {
    check_num_args 1 $# $FUNCNAME

    if [ ! -f "$1" ]; then
        throw "${2-Internal error: the file \"$1\" does not exist!}"
    fi
}

require() {
    check_num_args 1 $# $FUNCNAME

    check_file "$@"
    . "$1"
}

confirm() {
    check_num_args 1 $# $FUNCNAME

    read -p "$1 (Y/[n])? " -r
    [[ $REPLY =~ ^[Yy][Ee]?[Ss]?$ ]] || {
        if [ ! -z "$2" ]; then
            echo "$2"
        fi

        exit 0
        echo 1>&2
    }
}

# TODO: переместить в более подходящее место
get_ip() {
    IP=`ip -4 a l dev eth1  | grep inet | awk '{ print $2 }'`
    local pos=`expr index $IP /`
    [[ $pos -ne 0 ]] && {
        IP=${IP:0:(($pos-1))}
    }
}

# Copies elements from OPTIONS to ${MODULE}_OPTS
# Uses: OPTIONS, MODULES
assign_module_opts() {
    get_module_opts_var ${MODULES[0]}
    for opt in "${!OPTIONS[@]}"; do
        if [[ $opt = 'conf' ]]; then
            continue
        fi
        eval "$MODULE_OPTS_VAR[$opt]="${OPTIONS[$opt]}""
    done
}

# Имя массива, хранящего опции модуля
# $1 - module
get_module_opts_var() {
    check_num_args 1 $# $FUNCNAME
    local module=$1
    local var_name='OPTS'
    local upcase_module="$(echo $module | tr '[a-z]' '[A-Z]')"
    MODULE_OPTS_VAR="${upcase_module}_${var_name}"
}