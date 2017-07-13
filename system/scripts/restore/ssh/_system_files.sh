#!/bin/sh

cd /
tar -xzpf - /opt/engines/etc /opt/engines/run

#need to reset stuff that is dynamic
/opt/engines/system/scripts/startup/set_ip.sh
