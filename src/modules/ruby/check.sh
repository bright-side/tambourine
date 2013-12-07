#!/bin/bash

__namespace__() {

    MODULES_STATE['ruby']='INSTALLED'

    core::module::check_packs 'ruby'
    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['ruby']='NOT_INSTALLED'
        return
    fi

    [[ ${!RUBY_OPTS[@]} =~ u|(user) ]] && {
        local user=${RUBY_OPTS[$BASH_REMATCH]}
    } || {
        echo "Required option 'user' is not found"
        exit 1
    }
    grep "^$user:" /etc/passwd > /dev/null || {
        echo "User '$user' doesn't exist on your system! Failed to check module."
        exit 1
    }

    su $user -l -c 'ruby -v >& /dev/null' || {
        MODULES_STATE['ruby']='NOT_INSTALLED'
        return
    }
    
}; __namespace__
