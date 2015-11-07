#/bin/sh

hostname=`echo  $SSH_ORIGINAL_COMMAND | awk '{print $2}'`
sudo hostname $hostname
