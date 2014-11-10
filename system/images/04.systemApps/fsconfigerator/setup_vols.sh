#/bin/bash
#VOLUME /client/var/log
#VOLUME /client/log
#VOLUME /client/state
#VOLUME /client/fs
#VOLUME /dest/fs
chown $fw_user -R /client/log/
chown $fw_user -R /client/var/log
chown $fw_user -R /client/state/

cp -rp  client/fs* /dest/fs/


