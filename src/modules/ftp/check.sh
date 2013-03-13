#!/bin/bash

__namespace__() {

    MODULES_STATE['ftp']='INSTALLED'

    core::module::check_packs 'ftp'

    if [[ $PACKS_INSTALLED = false ]]; then
        MODULES_STATE['ftp']='NOT_INSTALLED'
        return
    fi

    local conf_file='/etc/vsftpd.conf'

    # Выключить анонимный доступ к FTP-серверу
    [[ ${!FTP_OPTS[@]} =~ a|(disable-anonymous) ]] && {
        grep '^anonymous_enable=NO$' $conf_file > /dev/null && {
            if [[ ${FTP_OPTS[$BASH_REMATCH]} = no ]]; then
                MODULES_STATE['ftp']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        } || {
            if [[ ${FTP_OPTS[$BASH_REMATCH]} != no ]]; then
                MODULES_STATE['ftp']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        }
    }

    # Дать возможность заходить на сервер локально
    [[ ${!FTP_OPTS[@]} =~ l|(enable-local) ]] && {
        grep '^local_enable=YES$' $conf_file > /dev/null && {
            if [[ ${FTP_OPTS[$BASH_REMATCH]} = no ]]; then
                MODULES_STATE['ftp']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        } || {ftp
            if [[ ${FTP_OPTS[$BASH_REMATCH]} != no ]]; then
                MODULES_STATE['ftp']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        }
    }

    # Разрешить закидывать файлы на сервер
    [[ ${!FTP_OPTS[@]} =~ w|(enable-write) ]] && {
        grep '^write_enable=YES$' $conf_file > /dev/null && {
            if [[ ${FTP_OPTS[$BASH_REMATCH]} = no ]]; then
                MODULES_STATE['ftp']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        } || {
            if [[ ${FTP_OPTS[$BASH_REMATCH]} != no ]]; then
                MODULES_STATE['ftp']='INSTALLED_WITH_OTHER_OPTIONS'
                return
            fi
        }
    }

}; __namespace__