#!/bin/bash

__namespace__() {

    MODULES_STATE['sudo']='INSTALLED'

    core::module::check_packs 'sudo'

    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['sudo']='NOT_INSTALLED'
        return
    fi

    local conf_file='/etc/sudoers'

    # Не требовать пароль при использовании sudo
    [[ ${!SUDO_OPTS[@]} =~ n|(nopasswd) ]] && {
    	grep '^%sudo ALL=(ALL) NOPASSWD: ALL$' $conf_file > /dev/null && {
            if [[ ${SUDO_OPTS[$BASH_REMATCH]} = no ]]; then
                MODULES_STATE['sudo']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        } || {
            if [[ ${SUDO_OPTS[$BASH_REMATCH]} != no ]]; then
                MODULES_STATE['sudo']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        }
    }
    
}; __namespace__
