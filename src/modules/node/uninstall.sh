#!/bin/bash

__namespace__() {

    core::module::purge_packs 'node'

    dpkg -r 'nodejs'

}; __namespace__