#!/bin/bash
ssh-keygen  -P "" -f /home/engines/.ssh/sshaccess >/dev/null
cat   /home/engines/.ssh/sshaccess.pub > authorized_keys
chmod og-rw  /home/engines/.ssh/authorized_keys
 cat  /home/engines/.ssh/sshaccess
rm  /home/engines/.ssh/sshaccess