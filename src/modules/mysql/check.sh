#!/bin/bash

__namespace__() {

    MODULES_STATE['mysql']='INSTALLED'

    core::module::check_packs 'mysql'

    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['mysql']='NOT_INSTALLED'
        return
    fi

    local conf_file='/etc/mysql/my.cnf'

    # Разрешить удаленный доступ
    [[ ${!MYSQL_OPTS[@]} =~ r|(remote-access) ]] && {
    	get_ip
    	grep "^bind-address = $IP$" $conf_file > /dev/null && {
    		if [[ ${MYSQL_OPTS[$BASH_REMATCH]} = no ]]; then
    			MODULES_STATE['mysql']='INSTALLED_WITH_OTHER_OPTIONS'
    			return
    		fi
		} || {
			if [[ ${MYSQL_OPTS[$BASH_REMATCH]} != no ]]; then
    			MODULES_STATE['mysql']='INSTALLED_WITH_OTHER_OPTIONS'
    			return
    		fi
		}
    }

}; __namespace__