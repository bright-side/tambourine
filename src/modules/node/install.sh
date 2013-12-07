#!/bin/bash

__namespace__() {

    [[ ${MODIFY[@]} =~ node ]] || {
        core::module::install_packs 'node'

        rm -rf /tmp/node-install
        mkdir /tmp/node-install
        cd /tmp/node-install

        wget --no-check-certificate http://nodejs.org/dist/node-latest.tar.gz

        tar -xzf node-latest.tar.gz
        rm node-latest.tar.gz

        # Извлекаем версию из имени папки
        local dirname=`find . -maxdepth 1 -name 'node-v*' -print`
        local version=${dirname:8}

        cd node-v*
        ./configure && make && checkinstall --install=yes --pkgname=nodejs --pkgversion=$version --default
        
        cd $MAIN_DIR
        rm -rf /tmp/node-install
    }

}; __namespace__