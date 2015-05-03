FROM  engines/servicebase:$release
RUN apt-get -y update;\
	apt-get -y install syslogd;\
	echo "Y" | adduser -q --disabled-password --home /home/auth -uid 22017 auth;\
	

COPY home home
USER auth

CMD /home/init.sh