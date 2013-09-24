#!/bin/bash

__namespace__() {

    MODULES_STATE['mongodb']='INSTALLED'

    core::module::check_packs 'mongodb'

    if [[ $PACK_INSTALLED = false ]]; then
        MODULES_STATE['mongodb']='NOT_INSTALLED'
        return
    fi
    
}; __namespace__
