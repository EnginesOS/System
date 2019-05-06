#!/bin/sh

user=`cat /home/engines/etc/user/name`

/usr/sbin/usermod -u $cont_uid $user


if test -f /home/engines/etc/user/files
 then
  for file in `cat /home/engines/etc/user/files`
   do
    chown $user $file
   done
fi
if test -f /home/engines/etc/user/dirs
 then
  for dir in  `cat /home/engines/etc/user/dirs`
   do
    mkdir -p $dir
    chown -R $user $dir
   done
fi

group=`cat /home/engines/etc/group/name`

/usr/sbin/groupmod -g $cont_uid $group

if test -f /home/engines/etc/group/files
 then
  for file in  `cat /home/engines/etc/group/files`
   do
    chown $group $file
   done
fi
if test -f /home/engines/etc/group/dirs
 then
  for dir in  `cat /home/engines/etc/group/dirs`
   do
   mkdir -p $dir
    chown -R $group $dir
   done
fi   

/usr/sbin/usermod -u $data_uid data-user
/usr/sbin/groupmod -g $data_gid data-user
/usr/sbin/usermod -g data-user data-user 
/usr/sbin/usermod -G data-user $user
/usr/sbin/usermod -g $group $user
/usr/sbin/usermod -G containers $user



