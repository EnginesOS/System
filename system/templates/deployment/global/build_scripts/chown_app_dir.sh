#!/bin/sh

echo PACKAGE_INSTALLER_RUN $PACKAGE_INSTALLER_RUN
 
if [ ! -d /home/app ]
 then 
   mkdir -p /home/app 
  fi
  
mkdir -p /home/fs ; mkdir -p /home/fs/local 
chown $data_uid -R /home/app /home/fs /home/fs/local   


 set_permissions()
{
user=`cat /home/engines/etc/user/name`

if test -f /home/engines/etc/user/files_post_install
 then
  for file in `cat /home/engines/etc/user/files_post_install`
   do
    if ! test -f $file
    then
     touch $file
    fi
    chown $user $file
   done
fi
if test -f /home/engines/etc/user/dirs_post_install
 then
  for dir in  `cat /home/engines/etc/user/dirs_post_install`
   do
    mkdir -p $dir
    chown -R $user $dir
   done
fi


group=`cat /home/engines/etc/group/name`
echo cat /home/engines/etc/group/name $group
if test -f /home/engines/etc/group/files_post_install
 then
  for file in  `cat /home/engines/etc/group/files_post_install`
   do
   echo touch $file
    if ! test -f $file
    then
     touch $file
    fi
      chown $group $file
   done
fi
if test -f /home/engines/etc/group/dirs_post_install
 then
  for dir in  `cat /home/engines/etc/group/dirs_post_install`
   do
   echo mkdir $dir
   mkdir -p $dir
    chown -R $group $dir
   done
fi   
}

set_permissions
 
  