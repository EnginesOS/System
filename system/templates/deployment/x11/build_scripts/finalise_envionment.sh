#!/bin/sh
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
apt-get -y remove  build-essential gcc make 
apt-get -y clean 

if ! test -z $X11COMMAND
 then
  echo "$X11COMMAND " >/home/app/.profile
fi 

