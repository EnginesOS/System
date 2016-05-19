#!/bin/sh

echo  $SSH_ORIGINAL_COMMAND | cut -f2- -d" " > /home/engines/.ssh/authorized_keys.console_access
 cat /home/engines/.ssh/authorized_keys.console_access /home/engines/.ssh/authorized_keys.system > /home/engines/.ssh/authorized_keys
chmod og-rw  /home/engines/.ssh/authorized_keys
