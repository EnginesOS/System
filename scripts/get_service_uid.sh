#!/bin/sh
grep _${1} /opt/engines/etc/container_uids |awk '{print $3}'