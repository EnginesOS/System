#!/bin/bash
touch /var/log/engines/last_start.log
chown engines /var/log/engines/last_start.log
 cat /etc/rc.local | sed "/^su -l engines.*$/s//su engines \/opt\/engines\/bin\/engines_startup.sh  > /tmp/rc.local
 mv /tmp/rc.local /etc
