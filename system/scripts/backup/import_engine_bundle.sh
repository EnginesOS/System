#!/bin/sh

mkdir -p /tmp/bundles
cat - > /tmp/t
cd /tmp/bundles
cat /tmp/t | sudo -n /opt/engines/system/scripts/backup/sudo/_import_engine_bundle.sh

