#!/bin/bash

__namespace__() {

    core::module::purge_packs 'ruby'

    # Удаление RVM и Ruby для указанного пользователя
    [[ ${!RUBY_OPTS[@]} =~ u|(user) ]] && {
        local user=${RUBY_OPTS[$BASH_REMATCH]}
    } || {
        echo "Required option 'user' is not found"
        exit 1
    }

    grep "^$user:" /etc/passwd > /dev/null || {
        echo "User '$user' doesn't exist on your system! Failed to uninstall module."
        exit 1
    }

    su $user -l -c 'rvm -v' >& /dev/null || {
        return
    }
    
    su $user -l -c 'rvm implode'
    su $user -l -c 'sed -e "/.rvm/d" -i ~/.profile ~/.bash_profile ~/.bashrc'

}; __namespace__