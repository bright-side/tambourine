#!/bin/bash

__namespace__() {
    
    MODULES_STATE['ssh']='INSTALLED'

    core::module::check_packs 'ssh'

    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['ssh']='NOT_INSTALLED'
        return
    fi

    local conf_file='/etc/ssh/sshd_config'

    # Номер порта
    if [[ ${!SSH_OPTS[@]} =~ p|(port) ]]; then
        local port=${SSH_OPTS[$BASH_REMATCH]}
        grep "^Port\s\+$port$" $conf_file > /dev/null || {
            MODULES_STATE['ssh']='INSTALLED_WITH_OTHER_OPTIONS'
            return
        }
    fi

    # Запрет прямого доступа по SSH для root
    [[ ${!SSH_OPTS[@]} =~ f|forbid-root ]] && {
        grep '^PermitRootLogin no$' $conf_file > /dev/null && {
            if [[ ${SSH_OPTS[$BASH_REMATCH]} = no ]]; then
                MODULES_STATE['ssh']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        } || {
            if [[ ${SSH_OPTS[$BASH_REMATCH]} != no ]]; then
                MODULES_STATE['ssh']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        }
    }

    # Файлы, необходимые для авторизации по публичным ключам
    if [[ ${!SSH_OPTS[@]} =~ a|(auth-keys-file) ]]; then
        local path=${SSH_OPTS[$BASH_REMATCH]}
        if [[ $path != 'no' ]]; then
            if [[ ! -f $path ]]; then
                MODULES_STATE['ssh']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        fi
    fi

}; __namespace__