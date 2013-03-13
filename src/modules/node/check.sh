#!/bin/bash

__namespace__() {

    MODULES_STATE['node']='INSTALLED'

    core::module::check_packs 'node'

    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['node']='NOT_INSTALLED'
        return
    fi

    core::module::check_pack_status_by_dpkg 'nodejs'

    if [[ $PACK_INSTALLED = false ]]; then
        MODULES_STATE['node']='NOT_INSTALLED'
        return
    fi
    
}; __namespace__