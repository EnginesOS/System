#/bin/sh

#VOLUME /client/var/log
#VOLUME /client/log
#VOLUME /client/state
#VOLUME /home/fs
#VOLUME /dest/fs
cp -rp /var/log/*  /client/var/log

chown $fw_user -R /client/log/
chown $fw_user -R /client/var/log
chown $fw_user -R /client/state/

files=`ls /dest/fs/`
if test -z $files
 then
  chown $fw_user /dest/fs/
else
	cp -rp  /home/fs/* /dest/fs/
fi


