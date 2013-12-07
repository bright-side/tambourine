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

    if [[ ${MODULES_STATE[$1]} = "NOT_INSTALLED" ]]; then
        return 1
    fi
}


core::module::perform_at_packs() {
    check_num_args 1 $# $FUNCNAME

    for pack in "${PACKS[@]}"; do
        apt-get $1 $pack -y || {
            echo "Error: failed to $1 the package \"$pack\"!"
            exit 1
        }
    done
}

# Prepare a list of packages to remove for the specified module
# Удаление пакетов, используемых другими модулями
core::module::get_unused_packs() {
    check_num_args 1 $# $FUNCNAME

    core::module::require_packs "$1"

    declare -a res_packs=("${PACKS[@]}")

    for module in "${STANDARD_MODULES[@]}"; do
        if [[ $1 != $module ]]; then

            [[ ${MODULES[@]} =~ $module ]] && {
                continue
            }

            core::module::check "$module"
            if [[ $MODULES_STATE[$module] = "NOT_INSTALLED" ]]; then
                continue
            fi

            core::module::require_packs "$module"

            local i=0
            while [[ $i -lt ${#PACKS[@]} ]]; do
                local j=0
                while [[ $j -lt ${#res_packs[@]} ]]; do
                    if [[ ${res_packs[$j]} == ${PACKS[$i]} ]]; then
                        res_packs=( ${res_packs[@]:0:$j} ${res_packs[@]:($j+1)} )
                    fi
                    j=$((j+1))
                done
                i=$((i+1))
            done
        fi
    done

    PACKS=(${res_packs[@]})
}

core::module::check_pack_status_by_apt() {
    check_num_args 1 $# $FUNCNAME
    local pack=$1
    PACK_INSTALLED=true
    local result=`aptitude search "^$pack$"`
        if [[ $? -ne 0 || -z $result ]]; then
            PACK_INSTALLED=false
            return
        fi
        local state=${result:0:1}
        if [[ $state = 'c' || $state = 'p' ]]; then
            PACK_INSTALLED=false
            return
        fi
}

core::module::check_pack_status_by_dpkg() {
    check_num_args 1 $# $FUNCNAME
    local pack=$1
    PACK_INSTALLED=true
    dpkg -s $pack >& /dev/null || {
        PACK_INSTALLED=false
        return
    }
    local info=`dpkg -s $pack`
    local pos=`awk -v a="$info" -v b="not-installed" 'BEGIN{print index(a,b)}'`
    if [[ $pos -ne 0 ]]; then
        PACK_INSTALLED=false
    fi
}

core::module::install_packs() {
    check_num_args 1 $# $FUNCNAME
    local module=$1

    core::module::require_packs $module
    core::module::perform_at_packs "install"
}

core::module::purge_packs() {
    check_num_args 1 $# $FUNCNAME
    local module=$1

    core::module::require_packs $module
    core::module::get_unused_packs $module
    core::module::perform_at_packs "purge"
    apt-get autoclean -y
    apt-get autoremove -y
}

core::module::check_packs() {
    check_num_args 1 $# $FUNCNAME
    local module=$1

    core::module::require_packs $module
    PACKS_INSTALLED=true

    for pack in "${PACKS[@]}"; do
        core::module::check_pack_status_by_apt $pack
        if [[ $PACK_INSTALLED = false ]]; then
            PACKS_INSTALLED=false
            return
        fi
    done
}