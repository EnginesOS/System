FROM  engines/servicebase
RUN echo "Y" | adduser -q --disabled-password --home /var/cache/bind -uid 21000 dockuser;\
	apt-get -y install rsyslog;\
	echo "cron.*                         /var/log/cron.log " > /etc/rsyslog.d/60-cron.conf 

COPY home home


CMD /home/init.sh