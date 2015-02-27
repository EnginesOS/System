From engines/base:$release
RUN echo "Y" | adduser -q --disabled-password  -uid 22013 dovecot;\
	echo "Y" | adduser -q --disabled-password  -uid 22014 --home /var/vmail  vmail
RUN apt-get -y update;\
	apt-get -y install  syslogd dovecot-core dovecot-imapd  dovecot-pop3d  dovecot-sieve dovecot-lmtpd dovecot-mysql ;\
	apt-get clean
ADD dovecot/10-master.conf /etc/dovecot/conf.d/
ADD dovecot/20-lmtp.conf /etc/dovecot/conf.d/
ADD dovecot/dovecot-sql.conf.ext /etc/dovecot/

ADD home home
