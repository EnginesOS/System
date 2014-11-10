FROM  engines/php
ADD home home
ADD engines home/engines
ADD cron/ /etc/cron.d


RUN cat /etc/apache2/sites-enabled/000-default.conf  | sed "s/^#SERVER_NAME/ ServerName $fqdn" > /tmp/.000-default.conf 
RUN cp /tmp/.000-default.conf  /etc/apache2/sites-enabled/000-default.conf 
		
CMD touch /var/run/startup_complete ;/usr/sbin/apache2ctl -D FOREGROUND ; rm -f /run/apache2/apache2.pid ;rm /engines/var/run/startup_complete



