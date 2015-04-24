From engines/servicebase:$release
RUN echo "Y" | adduser -q --disabled-password  -uid 22013 dovecot;\
	echo "Y" | adduser -q --disabled-password  -uid 22014 --home /var/vmail  vmail
RUN apt-get -y update;\
	apt-get -y install  syslogd dovecot-core=1:2.2.9-1ubuntu2 dovecot-imapd=1:2.2.9-1ubuntu2  dovecot-pop3d=1:2.2.9-1ubuntu2  dovecot-sieve=1:2.2.9-1ubuntu2 dovecot-lmtpd dovecot-mysql ;\
	apt-get clean ;\
	chown vmail /var/mail
	
ADD dovecot/conf.d /etc/dovecot/conf.d

ADD dovecot/dovecot-sql.conf.ext /etc/dovecot/

ADD home home
