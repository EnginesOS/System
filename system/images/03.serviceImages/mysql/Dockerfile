FROM  engines/servicebase:$release

RUN echo "Y" | adduser -q --disabled-password -uid 22006 mysql

RUN   apt-get -y update;\
	apt-get -y install mysql-server;\
	apt-get clean;\
	 cat /etc/mysql/my.cnf |grep -v  event-scheduler=DISABLED |sed "/127.0.0.1/s//0.0.0.0/" >/etc/mysql/my.cnf.sed;\
	mv /etc/mysql/my.cnf.sed /etc/mysql/my.cnf;\
	echo max_allowed_packet=4M >> /etc/mysql/my.cnf;\
	echo event-scheduler=1 >> /etc/mysql/my.cnf;\
	usermod -G containers -a mysql
ADD home home


EXPOSE 3306


ENV ContUser mysql
ENV ContGrp mysql


CMD /home/init.sh