#!/bin/bash

apt-get -y update
env DEBIAN_FRONTEND=noninteractive   apt-get -q -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" dist-upgrade
#DEBIAN_PRIORITY=critical
apt-get install -y apt-transport-https    linux-image-extra-$(uname -r) lvm2 thin-provisioning-tools
service docker restart 