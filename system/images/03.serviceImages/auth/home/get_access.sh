#!/bin/sh

service=`echo $SSH_ORIGINAL_COMMAND |  awk -F/ '{print $6}'`
cat /home/auth/static/access/$service/access
#echo $SSH_ORIGINAL_COMMAND
