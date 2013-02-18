#!/bin/bash

throw() {
    echo "$1"
    exit 1
}

check_num_args() {
    if [ $# -lt 3 ]; then
        throw
    fi

    if [ $1 -gt $2 ]; then
        throw
    fi
}

check_dir() {
    check_num_args 1 $# $FUNCNAME

    if [ ! -d "$1" ]; then
        throw "$2"
    fi
}

check_file() {
    check_num_args 1 $# $FUNCNAME

    if [ ! -f "$1" ]; then
        throw "$2"
    fi
}

require() {
    check_num_args 1 $# $FUNCNAME

    check_file $@
    . "$1"
}

function confirm() {
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