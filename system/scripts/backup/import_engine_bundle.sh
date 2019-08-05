#!/bin/sh

mkdir -p /tmp/bundles/$1
cat - > /tmp/t
cd /tmp/bundles/$1
cat /tmp/t | sudo -n /opt/engines/system/scripts/backup/sudo/_import_engine_bundle.sh $1

