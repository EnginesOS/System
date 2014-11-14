FROM  engines/php
ADD home home
ADD engines home/engines


RUN	if [ -f /home/engines/configs/php/71-custom.ini ] ;\
		then		\
			cp /home/engines/configs/php/71-custom.ini /etc/php5/apache2/conf.d/;\
	fi;\
	if [ -f /home/engines/configs/apache2/extra.conf ] ;\
		then \
			cp /home/engines/configs/apache2/extra.conf /etc/apache2/conf.d/;\
	fi	;\
	if [ -f /home/engines/configs/apache2/site.conf ] ;\
		then\
			cp /home/engines/configs/apache2/site.conf /etc/apache2/sites-enabled/000-default.conf;\
	fi;\
	mkdir -p /home/app
	

CMD touch /var/run/startup_complete ;/usr/sbin/apache2ctl -D FOREGROUND ; rm -f /run/apache2/apache2.pid ;rm /engines/var/run/startup_complete



