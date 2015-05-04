FROM engines/servicebase:$release
RUN echo "Y"| adduser --uid 22010 -q --home /home/ftpd --disabled-password proftpd;\
 	apt-get -y update;\
  	apt-get -y install proftpd proftpd-mod-mysql syslogd;\
	apt-get clean;\
	usermod -G containers -a proftpd
	
ADD proftpd.conf /etc/proftpd/
ADD tls.conf /etc/proftpd/
ADD sql.conf /etc/proftpd/
ADD modules.conf /etc/proftpd/
RUN mkdir /ftp/
ADD home home
#CMD proftpd -n
CMD /home/init.sh