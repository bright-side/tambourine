main::_version() {
    echo "0.0.3"
}

main::_build() {
    local lib_path="$PWD/lib.$SHELL_EXTENSION"

    if [ ! -f "$lib_path" ]; then
        echo "Internal error: the file \"$lib_path\" does not exist!"
        exit 1
    fi
    . "$lib_path"

    require "$PWD/commands.$SHELL_EXTENSION"
    require "$PWD/modules.$SHELL_EXTENSION"
    require "$PWD/core/environment.$SHELL_EXTENSION"
    require "$PWD/core/module.$SHELL_EXTENSION"

    for module in "${STANDARD_MODULES[@]}"; do
        core::module::check_completeness "$module"
    done
}

main::_check_uid() {
    if [ 0 -ne $UID ]; then
        throw "You must be root to make the Tambourine obey you!"
    fi
}

main::_init_command() {
    for arg; do
        if [[ "${STANDARD_COMMANDS[@]}" =~ "$arg" ]]; then
            COMMAND="$arg"
            break
        fi
    done

    if [ -z "$COMMAND" ]; then
        throw "You didn't specify a command for modules or this command is unknown to the Tambourine!"
    fi
}

main::_trim_modules() {
    local i=0
    local max=0

    while [ $i -lt "${#MODULES[@]}" ]; do
        local j=0

        while [ $j -lt "${#MODULES[@]}" ]; do
            if [ $i -ne $j ] && [[ "${MODULES[$i]}" == "${MODULES[$j]}" ]]; then
                (( max = i > j ? i : j ))

                MODULES=( "${MODULES[@]:0:$max}" "${MODULES[@]:($max+1)}" )

                i=-1
                break
            fi

            j=$((j+1))
        done

        i=$((i+1))
    done
}

main::_init_modules() {
    for arg; do
        if [[ "${STANDARD_MODULES[@]}" =~ "$arg" ]]; then
            if [[ ! "${MODULES[@]}" =~ "$arg" ]]; then
                MODULES[${#MODULES[@]}]=$arg
            fi
        fi
    done

    if [ -z "$MODULES" ]; then
        throw "You didn't specify modules to be ${COMMAND}ed or these modules are unknown to the Tambourine!"
    fi

    #main::_trim_modules
}

main::_init_options_by_conf() {
    local temp=`getopt -o : --long conf: -- "$@"`

    eval set -- "$temp"

    while true ; do
        case "$1" in
            --conf )
                local conf_path="$2"
                shift 2
                ;;
            -- ) shift; break;;
        esac
    done

    if [ -z "$conf_path" ]; then
        throw "You didn't specify a path to config file!"
    else
        # BUG: если путь к конфигу неправильный, выводит "The"
        require "$conf_path" "The specified config file \"$conf_path\" does not exist!"
    fi
}

main::_init_options_by_args() {
    declare -A options
    core::module::require_opts "${MODULES[0]}"

    local args=`getopt -o "$SHORT_OPTS" --long "$LONG_OPTS" -- "$@"`
    eval set -- "$args"

    while true; do
        if [[ -- = "$1" ]]; then
            shift
            break
        fi

        if [ 2 -eq ${#1} ]; then
            local opts="$SHORT_OPTS"
            local opt="${1:1}"

        else
            local opts="$LONG_OPTS"
            local opt="${1:2}"
        fi

        local pos=`awk -v a="$opts" -v b="$opt" 'BEGIN{print index(a,b)}'`
        pos=$(($pos+${#opt}-1))

        if [[ : == "${opts:$pos:1}" ]]; then
            options["$opt"]="$2"
            shift 2
        else
            options["$opt"]="true"
            shift
        fi
    done

    for opt in "${!options[@]}"; do
        eval "$(echo ${MODULES[0]} | tr '[a-z]' '[A-Z]')_OPTS[$opt]=${options[$opt]}"
    done
}

main::_init_options() {
    if [[ "$@" =~ "--conf" ]]; then
        main::_init_options_by_conf $@
        return 0
    fi

    if [ 1 -eq "${#MODULES[@]}" ]; then
        main::_init_options_by_args $@
    fi
}

main::_extend_modules_by_deps() {
    local exit_code=0;

    local i=0
    while [ $i -lt ${#MODULES[@]} ]; do
        core::module::require_deps "${MODULES[$i]}"

        for dep_module in "${DEPS[@]}"; do
            if [[ $dep_module == "${MODULES[$i]}" ]]; then
                echo "Warning: invalid dependency — module \"$dep_module\" is pointed at itself!"
                exit_code=2
                continue
            fi

            local buffer=( "${DEPS[@]}" )
            core::module::require_deps "$dep_module"
            if [[ "${DEPS[@]}" =~ "${MODULES[$i]}" ]]; then
                throw "Error: invalid dependency — modules (\"${MODULES[$i]}\", \"$dep_module\") are pointed at each other!"
            fi
            DEPS=( "${buffer[@]}" )

            local j=$i
            while [[ $j -lt ${#MODULES[@]} ]]; do
                if [[ $dep_module == ${MODULES[$j]} ]]; then
                    MODULES=( ${MODULES[@]:0:$j} ${MODULES[@]:($j+1)} )
                fi

                j=$((j+1))
            done

            if [[ ! "${MODULES[@]:$i-1}" =~ "$dep_module" ]]; then
                MODULES=( "${MODULES[@]:0:$i}" "$dep_module" "${MODULES[@]:$i}" )

                i=-1
                break
            fi
        done

        i=$((i+1))
    done

    return $exit_code
}

main::_exclude_installed_modules() {
    local i=0

    while [ $i -lt "${#MODULES[@]}" ]; do
        if [[ "INSTALLED" == "${MODULES_STATE[${MODULES[$i]}]}" ]]; then
            MODULES=( "${MODULES[@]:0:$i}" "${MODULES[@]:($i+1)}" )
            i=$((i-1))
        fi

        i=$((i+1))
    done
}

main::_report_modules_need_install() {
    declare -a need_install_modules

    for module in "${MODULES[@]}"; do
        if [[ ! "${ORIGINAL_MODULES[@]}" =~ "$module" ]] && [[ "NOT_INSTALLED" == "${MODULES_STATE[$module]}" ]]; then
            need_install_modules=( "${need_install_modules[@]}" "$module" )
        fi
    done

    if [ "${#need_install_modules[@]}" -gt 0 ]; then
        echo "In order to make the specified modules run correctly you need to install:"

        for module in "${need_install_modules[@]}"; do
            echo " * $module"
        done

        confirm "Continue installation" "Stopping installation..."
    fi
}

main::_report_modules_need_reinstall() {
    declare -a need_reinstall_modules

    for module in "${MODULES[@]}"; do
        if [[ "INSTALLED_WITH_OTHER_OPTIONS" == "${MODULES_STATE[$module]}" ]]; then
            if [[ ! ${need_reinstall_modules[@]} =~ $module ]]; then
                need_reinstall_modules=( "${need_reinstall_modules[@]}" "$module" )
            fi
        fi
    done

    if [ "${#need_reinstall_modules[@]}" -gt 0 ]; then
        echo "The following modules have been already installed, but with other options:"

        for module in "${need_reinstall_modules[@]}"; do
            echo " * $module"
        done

        confirm "Reinstall these modules with specified options" "Stopping installation..."
    fi
}

main::_report_can_break_modules() {
    declare -a modules_can_break

    for standard_module in "${STANDARD_MODULES[@]}"; do
        core::module::check "$standard_module"

        if [ 0 -eq $? ]; then
            core::module::require_deps "$standard_module"

            for module in "${MODULES[@]}"; do
                if [[ "${DEPS[@]}" =~ "$module" ]]; then
                    modules_can_break=( "${modules_can_break[@]}" "$standard_module" )

                    local i=0
                    while [ $i -lt "${#STANDARD_MODULES[@]}" ]; do
                        core::module::check "${STANDARD_MODULES[$i]}"

                        if [ 0 -eq $? ]; then
                            core::module::require_deps "${STANDARD_MODULES[$i]}"

                            if [[ "${STANDARD_MODULES[$i]}" != "$standard_module" ]] && [[ "${DEPS[@]}" =~ "$standard_module" ]]; then
                                modules_can_break=( "${modules_can_break[@]}" "${STANDARD_MODULES[$i]}" )

                                standard_module="${STANDARD_MODULES[$i]}"
                                i=-1
                                continue
                            fi
                        fi

                        i=$((i+1))
                    done
                fi
            done
        fi
    done

    if [ "${#modules_can_break[@]}" -gt 0 ]; then
        echo "Uninstalling specified modules may cause troubles in:"

        for module in "${modules_can_break[@]}"; do
            echo " * $module"
        done

        confirm "Confirm uninstall" "Stopping uninstallation..."
    fi
}


main::_report_modules_states() {
    for module in "${MODULES[@]}"; do
        case "${MODULES_STATE[$module]}" in
            "INSTALLED" )
                echo "The module \"$module\" is installed."
                ;;
            "INSTALLED_WITH_OTHER_OPTIONS" )
                echo "The module \"$module\" is installed, but with other options."
                ;;
            "NOT_INSTALLED" )
                echo "The module \"$module\" is not installed."
                ;;
        esac
    done
}
