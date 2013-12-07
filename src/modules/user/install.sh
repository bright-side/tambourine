#!/bin/bash

__namespace__() {

    [[ ${!USER_OPTS[@]} =~ l|(login) ]] && {
        local login=${USER_OPTS[$BASH_REMATCH]}
    } || {
        echo "Required option 'login' is not found"
        exit 1
    }

    [[ ${MODIFY[@]} =~ user ]] || {
        core::module::install_packs 'user'

        core::module::check_pack_status_by_apt 'whois'
        local purge_whois=false
        if [[ $PACK_INSTALLED = false ]]; then
            apt-get install -y whois > /dev/null
            purge_whois=true
        fi

        [[ ${!USER_OPTS[@]} =~ p|(password) ]] && {
            local password=${USER_OPTS[$BASH_REMATCH]}
        } || {
            echo "Required option 'password' is not found"
            exit 1
        }

        local conf_file='/etc/passwd'

        grep "^$login:" $conf_file >/dev/null && {
            echo "User '$login' already exists!"
        } || {
            local salt=`tr -dc 0-9 < /dev/urandom | head -c 2 | xargs`
            local crypted_pass=`mkpasswd $password $salt`
            useradd -m -s /bin/bash -p $crypted_pass $login && echo "User '$login' has been successfully added to system!" || {
                echo "Failed to add a user!"
                exit 1
            }
        }

        if [[ $purge_whois = true ]]; then
            apt-get purge -y whois > /dev/null
            apt-get -y autoclean
            apt-get -y autoremove
        fi
    }

    # Добавить пользователя в группу 'sudo' (или удалить)
    [[ ${!USER_OPTS[@]} =~ s|(sudoer) ]] && {
        core::module::check_pack_status_by_apt 'sudo'
        if [[ ${USER_OPTS[$BASH_REMATCH]} != no ]]; then
            usermod -a -G sudo $login || {
                echo "Failed to add a user to the 'sudo' group!"
                exit 1
            }
        else
            echo $login
            deluser $login sudo
        fi
    }

}; __namespace__