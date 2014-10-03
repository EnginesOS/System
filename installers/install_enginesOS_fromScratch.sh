#!/bin/bash

RUBY_VER=2.1.2

export RUBY_VER

. routines.sh


dpkg-reconfigure tzdata


make_dirs

set_permissions

install_docker_and_components

passwd dockuser

su -l dockuser /bin/bash ./complete_install.sh

 