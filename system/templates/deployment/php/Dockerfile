FROM  engines/php
ADD home home
ADD engines home/engines
ADD cron/ /etc/cron.d

CMD touch /var/run/startup_complete ;/usr/sbin/apache2ctl -D FOREGROUND ; rm -f /run/apache2/apache2.pid ;rm /engines/var/run/startup_complete



