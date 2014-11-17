#/bin/sh

#VOLUME /client/var/log
#VOLUME /client/log
#VOLUME /client/state
#VOLUME /home/fs
#VOLUME /dest/fs

logs=`ls /var/log/`
echo logs
for log in $logs
 do
	cp -rp /var/log/$log  /client/var/log
done

chown $fw_user -R /client/log/
chown $fw_user -R /client/var/log
chown $fw_user -R /client/state/

files=`ls /dest/fs/
if test -f /dest/fs/.persistant
 then
  chown $fw_user /dest/fs/
else
	cp -rp  /home/fs/* /dest/fs/
	touch /dest/fs/.persistant
fi


