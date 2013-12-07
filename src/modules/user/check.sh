#!/bin/bash

__namespace__() {

    MODULES_STATE['user']='INSTALLED'

    core::module::check_packs 'user'

    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['user']='NOT_INSTALLED'
        return
    fi

    local conf_file='/etc/passwd'

    [[ ${!USER_OPTS[@]} =~ l|(login) ]] && {
        local login=${USER_OPTS[$BASH_REMATCH]}
        grep "^$login:" $conf_file > /dev/null || {
            MODULES_STATE['user']='NOT_INSTALLED'
            return
        }
    } || {
        echo "Required option 'login' is not found"
        exit 1
    }

    # Пользователь добавлен в группу sudo
    [[ ${!USER_OPTS[@]} =~ s|(sudoer) ]] && {
        id $login | grep "sudo" > /dev/null && {
            if [[ ${USER_OPTS[$BASH_REMATCH]} = no ]]; then
                MODULES_STATE['user']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi   
        } || {
            if [[ ${USER_OPTS[$BASH_REMATCH]} != no ]]; then
                MODULES_STATE['user']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        }
    }

}; __namespace__