#!/bin/bash

__namespace__() {

    [[ ${MODIFY[@]} =~ nginx ]] || {
        core::module::install_packs 'nginx'
        
        rm -rf /tmp/nginx-install
        mkdir /tmp/nginx-install
        cd /tmp/nginx-install

        wget --no-check-certificate http://nginx.org/download/nginx-1.2.7.tar.gz

        tar -xzf nginx-*.tar.gz
        rm nginx-*.tar.gz

        NGINX_HOME='/usr/local/nginx'

        local options="--prefix=$NGINX_HOME"

        [[ ${!NGINX_OPTS[@]} =~ a|(auth) ]] && {
            if [[ ${NGINX_OPTS[$BASH_REMATCH]} != no ]]; then
                wget --no-check-certificate https://github.com/samizdatco/nginx-http-auth-digest/tarball/master -O master.tar.gz
                tar -xzf master.tar.gz
                rm master.tar.gz
                options="$options --add-module=../samizdatco-nginx-http-auth-digest-*"

                # При компиляции вылетает ошибка из-за неиспользуемой переменной, т.к. установлен флаг -Werror
                # Cratch: убрать флаг
                sed -e "s/^CFLAGS=\"\$CFLAGS -Werror\"\$/# CFLAGS=\"\$CFLAGS -Werror\"/" -i nginx-*/auto/cc/gcc
            fi
        }

        [[ ${!NGINX_OPTS[@]} =~ g|(gzip-static) ]] && {
            if [[ ${NGINX_OPTS[$BASH_REMATCH]} != no ]]; then
                options="$options --with-http_gzip_static_module"
            fi
        }

        cd nginx-*
        ./configure $options
        make && checkinstall --install=yes --pkgname=nginx --default

        cd $MAIN_DIR
        rm -rf /tmp/nginx-install

        mkdir -p $NGINX_HOME/logs

        INIT_FILE="$MAIN_DIR/$MODULES_PATH/nginx/init-script.sh"
        check_file $INIT_FILE
        cp $INIT_FILE /etc/init.d/nginx
        chmod +x /etc/init.d/nginx
        /usr/sbin/update-rc.d -f nginx defaults
    }

}; __namespace__