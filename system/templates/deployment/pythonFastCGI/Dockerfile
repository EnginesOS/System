FROM  engines/python
ADD home home
ADD engines home/engines

RUN chown 2671 `find /var /usr/share /usr/local /home -user www-data`;\
	/usr/sbin/usermod -u 2671 www-data
