#!/bin/bash
RUBY_VER=2.1.2
export RUBY_VER
. /opt/engos/installers/routines.sh


dpkg-reconfigure tzdata


make_dirs

set_permissions

install_docker_and_components



 