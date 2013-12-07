#!/bin/bash

__namespace__() {

    MODULES_STATE['nginx']='INSTALLED'

    core::module::check_packs 'nginx'

    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['nginx']='NOT_INSTALLED'
        return
    fi

    core::module::check_pack_status_by_dpkg 'nginx'

    if [[ $PACK_INSTALLED = false ]]; then
        MODULES_STATE['nginx']='NOT_INSTALLED'
        return
    fi

    if [[ ${!NGINX_OPTS[@]} =~ a|(auth) ]]; then
        : 'local port=${NGINX_OPTS[$BASH_REMATCH]}
        if [[ -z `grep "^Port\s\+$port" $conf_file` ]]; then
            MODULES_STATE["nginx"]="INSTALLED_WITH_OTHER_OPTIONS"
            return
        fi'
    fi

    if [[ ${!NGINX_OPTS[@]} =~ g|(gzip-static) ]]; then
        : 'local port=${NGINX_OPTS[$BASH_REMATCH]}
        if [[ -z `grep "^Port\s\+$port" $conf_file` ]]; then
            MODULES_STATE["nginx"]="INSTALLED_WITH_OTHER_OPTIONS"
            return
        fi'
    fi

}; __namespace__