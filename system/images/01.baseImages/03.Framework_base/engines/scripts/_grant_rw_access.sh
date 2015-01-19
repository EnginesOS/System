#!/bin/sh
path=`echo $1 |sed '/[ ;\\\"\`]/s///g ' | sed '/\.\./s///g'`
#FIXME needs to handle target of symbolic link
echo chmod g+w /home/$path
 chmod g+w /home/$path
 