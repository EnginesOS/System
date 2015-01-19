FROM  engines/servicebase
RUN apt-get -y update;\
	echo "Y" | adduser -q --disabled-password --home /var/cache/bind -uid 21000 dockuser;\
	apt-get -y install rsyslog;\
	apt-get clean ;\
	echo "cron.*                         /var/log/cron.log " > /etc/rsyslog.d/60-cron.conf 

COPY home home


CMD /home/init.sh