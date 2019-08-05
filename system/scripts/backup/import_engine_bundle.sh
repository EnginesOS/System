#!/bin/sh

mkdir -p /tmp/bundles
cat - > /tmp/t
cat /tmp/t | sudo -n /opt/engine/system/scripts/backup/sudo/_import_engine_bundle.sh

