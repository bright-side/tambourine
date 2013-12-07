#!/bin/bash

__namespace__() {

    core::module::purge_packs 'sudo'

    rm /etc/sudoers

}; __namespace__