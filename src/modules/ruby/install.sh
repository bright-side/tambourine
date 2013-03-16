#!/bin/bash

__namespace__() {

    [[ ${MODIFY[@]} =~ ruby ]] || {
        core::module::install_packs 'ruby'
    }

    # Установка RVM и Ruby для указанного пользователя
    [[ ${!RUBY_OPTS[@]} =~ u|(user) ]] && {
        local user=${RUBY_OPTS[$BASH_REMATCH]}
    } || {
        echo "Required option 'user' is not found"
        exit 1
    }

    grep "^$user:" /etc/passwd > /dev/null || {
        echo "User '$user' doesn't exist on your system! Failed to install module."
        exit 1
    }

    local curl_conf="/home/$user/.curlrc"

    if [[ ! -f $curl_conf ]]; then
        echo insecure >> $curl_conf
    else
        grep 'insecure' $curl_conf || {
            echo insecure >> $curl_conf
        }
    fi
    su $user -l -c "curl -#L https://get.rvm.io | bash -s stable --ruby"
    su $user -l -c "source /home/$user/.rvm/scripts/rvm"

}; __namespace__