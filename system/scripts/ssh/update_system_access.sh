#!/bin/sh

cat - > /home/engines/.ssh/authorized_keys.console_access
 cat /home/engines/.ssh/authorized_keys.console_access /home/engines/.ssh/authorized_keys.system > /home/engines/.ssh/authorized_keys
chmod og-rw  /home/engines/.ssh/authorized_keys
touch /tmp/key_done
exit 0
