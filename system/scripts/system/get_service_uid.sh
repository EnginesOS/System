#!/bin/sh
grep _${1} /opt/engines/etc/exported/container_uids |awk '{print $3}' | head -1