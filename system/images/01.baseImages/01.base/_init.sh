#/bin/sh
if  test -z $ContUser
        then
                ContUser=www-data
fi

if  test -z $ContGrp
        then
                ContGrp=www-data
fi

echo  u $ContUser  g $ContGrp  

adduser -q --home /home/app --disabled-password  $ContUser
addgroup $ContGrp

if test -f /home/fs.env
        then
		. /home/fs.env
                chown -R $ContUser.$ContGrp  $CONTFSVolHome
fi

chown -R  $ContUser.$ContGrp /home/app


mkdir -p /var/run/lock/
chgrp  $ContGrp /var/run/lock/
chmod g+w /var/run/lock/
su -l -s /bin/bash $ContUser /home/configcontainer.sh
