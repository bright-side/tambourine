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