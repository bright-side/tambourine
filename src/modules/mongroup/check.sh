#!/bin/bash

__namespace__() {

    MODULES_STATE['mongroup']='INSTALLED'

    core::module::check_packs 'mongroup'

    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['mongroup']='NOT_INSTALLED'
        return
    fi

    core::module::check_pack_status_by_dpkg 'mongroup'

    if [[ $PACK_INSTALLED = false ]]; then
        MODULES_STATE['mongroup']='NOT_INSTALLED'
        return
    fi

}; __namespace__