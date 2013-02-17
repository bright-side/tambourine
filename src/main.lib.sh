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