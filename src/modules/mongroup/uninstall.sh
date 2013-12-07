#!/bin/bash

__namespace__() {

    core::module::purge_packs 'mongroup'

    dpkg -r mongroup

    dpkg -r mon

}; __namespace__