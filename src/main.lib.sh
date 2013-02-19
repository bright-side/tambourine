main::_version() {
    echo "0.0.0"
}

main::_build() {
    local lib_path="$PWD/lib.$SHELL_EXTENSION"

    if [ ! -f "$lib_path" ]; then
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
        throw
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
        throw
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
            MODULES[${#MODULES[@]}]=$arg
        fi
    done

    if [ -z "$MODULES" ]; then
        throw
    fi

    main::_trim_modules
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
        throw
    else
        require "$conf_path"
    fi
}

main::_init_options_by_args() {
    declare -a options
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
                exit_code=2
                continue
            fi

            local buffer=( "${DEPS[@]}" )
            core::module::require_deps "$dep_module"
            if [[ "${DEPS[@]}" =~ "${MODULES[$i]}" ]]; then
                throw
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