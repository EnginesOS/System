#!/bin/sh
BUNDLE_DIR=/tmp/backup_bundles/
mkdir -p $BUNDLE_DIR/$1

cd $BUNDLE_DIR/$1
cat - | sudo -n /opt/engines/system/scripts/backup/sudo/_import_engine_bundle.sh $1

