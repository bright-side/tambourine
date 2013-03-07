#!/usr/bin/env bats

load main.lib
load main::environment.mock
load core::environment.mock
load throw.mock

transitivity_deps() {
    case "$1" in
        module_1 )
            DEPS=(  )
            ;;
        module_2 )
            DEPS=( module_1 )
            ;;
        module_3 )
            DEPS=( module_2 )
            ;;
        module_4 )
            DEPS=( module_3 )
            ;;
    esac
}

@test "The list of modules is empty" {
    MODULES=()

    main::_extend_modules_by_deps

    [[ "${MODULES[@]}" == "" ]]
}

@test "The list of modules consists of nonexistent modules" {
    core::module::require_deps() {
        exit 1
    }

    MODULES=( nonexistent_module )

    run main::_extend_modules_by_deps

    [ "$status" -eq 1 ]
}

@test "The list of modules consists of module that is pointed at itself" {
    core::module::require_deps() {
        DEPS=( self_meet_module )
    }

    MODULES=( self_meet_module )

    run main::_extend_modules_by_deps

    [ "$status" -eq 2 ]
}

@test "The list of modules consists of independent modules" {
    core::module::require_deps() {
        DEPS=()
    }

    MODULES=( module_1 module_2 )

    main::_extend_modules_by_deps

    [[ "${MODULES[@]}" == "module_1 module_2" ]]
}

@test "The list of modules consists of meet modules" {
    core::module::require_deps() {
        case "$1" in
            module_1 )
                DEPS=( module_2 )
                ;;
            module_2 )
                DEPS=( module_1 )
                ;;
        esac
    }

    MODULES=( module_1 module_2 )

    run main::_extend_modules_by_deps

    [ "$status" -eq 1 ]
}

@test "The list of modules consists of transitivity" {
    core::module::require_deps() {
        transitivity_deps $@
    }

    MODULES=( module_4 )

    main::_extend_modules_by_deps

    [[ "${MODULES[@]}" == "module_1 module_2 module_3 module_4" ]]
}

@test "The list of modules consists of transitivity modules in direct order" {
    core::module::require_deps() {
        transitivity_deps $@
    }

    MODULES=( module_1 module_2 module_3 module_4 )

    main::_extend_modules_by_deps

    [[ "${MODULES[@]}" == "module_1 module_2 module_3 module_4" ]]
}

@test "The list of modules consists of transitivity modules in reverse order" {
    core::module::require_deps() {
        transitivity_deps $@
    }

    MODULES=( module_4 module_3 module_2 module_1 )

    main::_extend_modules_by_deps

    [[ "${MODULES[@]}" == "module_1 module_2 module_3 module_4" ]]
}

@test "The list of modules consists of repetitions" {
    core::module::require_deps() {
        DEPS=()
    }

    MODULES=( module_1 module_1 module_1 module_1 )

    main::_extend_modules_by_deps

    [[ "${MODULES[@]}" == "module_1 module_1 module_1 module_1" ]]
}
