#!/bin/bash

__namespace__() {

    MODULES_STATE['backup']='INSTALLED'

    core::module::check_packs 'backup'
    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['backup']='NOT_INSTALLED'
        return
    fi

    # Пользователь, для которого требуется проверить установку gem-а
    [[ ${!BACKUP_OPTS[@]} =~ u|(user) ]] && {
        local user=${BACKUP_OPTS[$BASH_REMATCH]}
    } || {
        echo "Required option 'user' is not found"
        exit 1
    }
    grep "^$user:" /etc/passwd > /dev/null || {
        echo "User '$user' doesn't exist on your system! Failed to check module."
        exit 1
    }

    su $user -l -c "gem help" >& /dev/null || {
        MODULES_STATE['backup']='NOT_INSTALLED'
        return
    }

    su $user -l -c "gem list | grep 'backup' >& /dev/null" || {
        MODULES_STATE['backup']='NOT_INSTALLED'
        return
    }

    # Установка Ruby для конкретного пользователя
    [[ ${!BACKUP_OPTS[@]} =~ u|(user) ]] && {
        if [[ ! -d "/home/$user/.rvm" ]]; then
            MODULES_STATE['backup']='INSTALLED_WITH_OTHER_OPTIONS'
            return
        fi
    }
    
}; __namespace__
