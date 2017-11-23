#!/bin/sh
grep _${1} /opt/engines/etc/exported/service_uids |awk '{print $3}' | head -1