#!/bin/bash

__namespace__() {

    core::module::purge_packs 'nginx'

    dpkg -r nginx

    rm -r /usr/local/nginx

}; __namespace__