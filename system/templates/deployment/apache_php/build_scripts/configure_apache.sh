#!/bin/bash
cp /etc/apache2/sites-enabled/000-default.conf /tmp/000-default.conf.orig
www_dir=''
 if ! test -z  $WWW_DIR
  then
	www_dir=`basename $WWW_DIR`
  fi
cat /etc/apache2/sites-enabled/000-default.conf  | sed "s/WWW_DIR/$www_dir/" > /tmp/.000-default.conf
cat  /tmp/.000-default.conf  | sed "s/^#SERVER_NAME/ ServerName $fqdn/" > /tmp/.000-default.conf-2
cp /tmp/.000-default.conf-2 /etc/apache2/sites-enabled/000-default.conf 
echo  ServerName $fqdn > /tmp/apache2.conf
cat /etc/apache2/apache2.conf >> /tmp/apache2.conf
mv /tmp/apache2.conf /etc/apache2/apache2.conf 

	if [ -f /home/engines/configs/php/01-custom.ini ] 
		then		
			cp /home/engines/configs/php/01-custom.ini /etc/php/7.0/apache2/conf.d/
	fi
	if [ -f /home/engines/configs/apache2/extra.conf ] 
		then 
			cp /home/engines/configs/apache2/extra.conf /etc/apache2/conf-enabled/
	fi	
	if [ -f /home/engines/configs/apache2/site.conf ] 
		then
			cp /home/engines/configs/apache2/site.conf /etc/apache2/sites-enabled/000-default.conf
	fi
	
/build_scripts/install_htacess.sh
