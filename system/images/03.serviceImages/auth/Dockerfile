FROM  engines/servicebase:$release
RUN apt-get -y update;\
	apt-get -y install syslogd openssh-server ;\
	echo "Y" | adduser -q --disabled-password --home /home/auth -uid 22017 auth
	

COPY home home
RUN chown -T auth /home/auth

USER auth

CMD /home/init.sh