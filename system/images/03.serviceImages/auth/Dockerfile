FROM  engines/servicebase:$release
RUN apt-get -y update;\
	apt-get -y install syslogd openssh-server mysql-client ;\
	echo "Y" | adduser -q --disabled-password --home /home/auth -uid 22017 auth
	

COPY home home
RUN chown -R auth /home/auth

USER auth

CMD /home/init.sh