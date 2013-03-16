#!/bin/bash

__namespace__() {

    core::module::purge_packs 'backup'

    [[ ${!BACKUP_OPTS[@]} =~ u|(user) ]] && {
        local user=${BACKUP_OPTS[$BASH_REMATCH]}
    } || {
        echo "Required option 'user' is not found"
        exit 1
    }
    grep "^$user:" /etc/passwd > /dev/null || {
        echo "User '$user' doesn't exist on your system! Failed to uninstall module."
        exit 1
    }

    gem -v >& /dev/null || {
        return
    }

    su $user -l -c 'gem uninstall backup'

}; __namespace__