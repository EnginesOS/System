FROM  engines/python
ADD home home
ADD engines home/engines
ADD cron/ /etc/cron.d
RUN chown 22671 `find /var /usr/share /usr/local /home -user www-data`;\
	/usr/sbin/usermod -u 22671 www-data
