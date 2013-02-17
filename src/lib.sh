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