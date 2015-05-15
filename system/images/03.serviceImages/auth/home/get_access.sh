#!/bin/sh
echo $SSH_ORIGINAL_COMMAND
service=`echo $SSH_ORIGINAL_COMMAND |  awk -F/ '{print $5}'`
cat /home/auth/static/access/$service/access
