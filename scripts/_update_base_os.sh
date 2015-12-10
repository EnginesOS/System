#!/bin/bash

apt-get -y update
env DEBIAN_FRONTEND=noninteractive   apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade
#DEBIAN_PRIORITY=critical