FROM engines/servicebase:$release
RUN echo "Y"| adduser --uid 22010 -q --home /home/ftpd --disabled-password proftpd;\
 	apt-get -y update;\
  	apt-get -y install proftpd proftpd-mod-mysql syslogd  ;\
	apt-get clean;\
	usermod -G containers -a proftpd

COPY proftpd /etc/proftpd/
ADD sudoers /etc/sudoers

RUN mkdir /ftp/
ADD home home

USER proftpd

CMD /home/init.sh