#!/bin/bash

__namespace__() {

    function secure_installation {
        aptitude -y install expect
         
        SECURE_MYSQL=$(expect -c "

        spawn mysql_secure_installation
         
        expect \"Enter current password for root (enter for none):\"
        send \"${MYSQL_OPTS[root-password]}\r\"
         
        expect \"Change the root password?\"
        send \"n\r\"
         
        expect \"Remove anonymous users?\"
        send \"y\r\"
         
        expect \"Disallow root login remotely?\"
        send \"y\r\"
         
        expect \"Remove test database and access to it?\"
        send \"y\r\"
         
        expect \"Reload privilege tables now?\"
        send \"y\r\"
         
        expect eof
        ")
         
        echo "$SECURE_MYSQL"
         
        aptitude -y purge expect
    }

    [[ ${MODIFY[@]} =~ mysql ]] || {

	[[ ${!MYSQL_OPTS[@]} =~ (root-password) ]] && {
            debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_OPTS[root-password]}"
            debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_OPTS[root-password]}"
        }

        core::module::install_packs 'mysql'
        secure_installation
    }

    local conf_file='/etc/mysql/my.cnf'

    # Разрешить удаленный доступ
    [[ ${!MYSQL_OPTS[@]} =~ r|(remote-access) ]] && {
        local param='bind-address'
        if [[ ${MYSQL_OPTS[$BASH_REMATCH]} != no ]]; then
            get_ip
        	local value=$IP
        else
            local value='127.0.0.1'
        fi
        sed -e "s/^$param\s\+=\s\+[0-9\.]\+/$param = $value/" -i $conf_file
        /etc/init.d/mysql restart
    }

    # Во избежание ошибки "Can't get hostname for your address"
    sed -e "s/\[mysqld\]/&\nskip-name-resolve/ " -i $conf_file

}; __namespace__