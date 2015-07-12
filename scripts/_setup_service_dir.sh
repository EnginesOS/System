#!/bin/sh

sudo /opt/engines/scripts/_setup_service_key_dir.sh $1
sudo mkdir -p /opt/engines/run/services/$1/run
chgrp containers  /opt/engines/run/services/$1/run
chmod g+w  /opt/engines/run/services/$1/run
