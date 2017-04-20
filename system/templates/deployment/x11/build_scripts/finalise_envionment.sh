#!/bin/sh

apt-get -y remove  build-essential gcc make 
apt-get -y clean 

if ! test -z $X11COMMAND
 then
  echo "$X11COMMAND " >/home/app/.profile
fi 

