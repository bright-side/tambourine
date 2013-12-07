#!/bin/bash

__namespace__() {

    [[ ${MODIFY[@]} =~ backup ]] || {
        core::module::install_packs 'backup'
    }

    # Пользователь, для которого устанавливается backup gem
    [[ ${!BACKUP_OPTS[@]} =~ u|(user) ]] && {
        local user=${BACKUP_OPTS[$BASH_REMATCH]}
    } || {
        echo "Required option 'user' is not found"
        exit 1
    }
    grep "^$user:" /etc/passwd > /dev/null || {
        echo "User '$user' doesn't exist on your system! Failed to install module."
        exit 1
    }

    su $user -l -c "gem install backup"
    su $user -l -c "backup dependencies --install dropbox-sdk"
    su $user -l -c "backup dependencies --install mail"

}; __namespace__