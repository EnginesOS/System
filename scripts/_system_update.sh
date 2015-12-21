#!/bin/bash

apt-get -y update
apt-get -y upgrade 
apt-get -y upgrade lxc-docker
# ensure ufs installed
apt-get install -y apt-transport-https    linux-image-extra-$(uname -r) lvm2 thin-provisioning-tools 
apt-get -y autoremove
sudo apt-get clean

