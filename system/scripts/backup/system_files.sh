#!/bin/sh
cat - | sudo -n /opt/engines/system/scripts/backup/sudo/_system_files.sh

#tar -czpf - /opt/engines/etc /opt/engines/run