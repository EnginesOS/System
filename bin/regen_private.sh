#!/bin/bash
ssh-keygen  -P "" -f /home/engines/.ssh/console_access >/dev/null
cat   /home/engines/.ssh/console_access.pub > /home/engines/.ssh/authorized_keys.console_access
cat /home/engines/.ssh/authorized_keys.console_access /home/engines/.ssh/authorized_keys.system  > /home/engines/.ssh/authorized_keys
chmod og-rw  /home/engines/.ssh/authorized_keys
 cat  /home/engines/.ssh/console_access
rm  /home/engines/.ssh/console_access


