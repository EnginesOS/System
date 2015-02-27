From engines/base:$release
RUN echo "Y" | adduser -q --disabled-password  -uid 22013 dovecot;\
	echo "Y" | adduser -q --disabled-password  -uid 22014 --home /var/vmail  vmail
RUN apt-get -y update;\
	apt-get -y install  syslogd dovecot-core dovecot-imapd  dovecot-pop3d  dovecot-sieve dovecot-lmtpd dovecot-mysql ;\
	apt-get clean ;\
	chown vmail /var/mail
	
ADD dovecot/conf.d /etc/dovecot/conf.d

ADD dovecot/dovecot-sql.conf.ext /etc/dovecot/

ADD home home
