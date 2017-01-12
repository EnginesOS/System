#!/bin/bash
sudo apt-get upgrade -y linux-image-extra-$(uname -r) 
su  engines \/opt\/engines\/bin\/engines_startup.sh