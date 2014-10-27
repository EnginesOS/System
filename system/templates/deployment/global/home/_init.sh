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

#adduser -q --home /home/app --disabled-password  $ContUser
#addgroup $ContGrp

if test -f /home/fs.env
        then
		. /home/fs.env
                chown -R $ContUser.$ContGrp  $CONTFSVolHome
                echo "chown -R $ContUser.$ContGrp  $CONTFSVolHome"
fi

chown -R  $ContUser.$ContGrp /home/app
chown -R  $ContUser.$ContGrp `cat /home/LOG_DIR`
if test -f /home/app.env
	then
		. /home/app.env
		export ` cat /home/app.env |grep = |cut -f1 -d=`
fi
 

 

su -l -s /bin/bash $ContUser /home/configcontainer.sh
