#!/bin/bash

__namespace__() {

    [[ ${MODIFY[@]} =~ mongroup ]] || {
        core::module::install_packs 'mongroup'
        
        if [[ ! -d '/usr/local/bin' ]]; then
            mkdir '/usr/local/bin'
        fi

        # Установка mon
        mkdir /tmp/mon 
        cd /tmp/mon 
        wget --no-check-certificate https://github.com/visionmedia/mon/archive/master.tar.gz
        tar -xzvf master.tar.gz
        rm master.tar.gz
        cd mon-master
        
        # Получаем версию из файла package.json
        local buf_array=(`head -n 3 package.json`)
        local version_str=${buf_array[4]}
        local version=${version_str:1:(-2)}

        checkinstall --install=yes --pkgname=mon --pkgversion=$version --default
        cd $MAIN_DIR
        rm -r /tmp/mon

        mkdir -p /tmp/mongroup
        cd /tmp/mongroup
        wget --no-check-certificate 'https://github.com/jgallen23/mongroup/archive/master.tar.gz'
        tar -xzf 'master.tar.gz'
        cd mongroup-master
        
        # Получаем версию из файла bin/mongroup
        buf_array=(`head -n 3 bin/mongroup`)
        version_str=${buf_array[1]}
        version=${version_str:9:(-1)}

        echo $version > /home/bright/shared/tamb/src/log
        checkinstall --install=yes --pkgname=mongroup --pkgversion=$version --default

        cd $MAIN_DIR
        rm -r /tmp/mongroup
    }

}; __namespace__