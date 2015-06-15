From engines/servicebase:$release
RUN adduser -q --disabled-password  -uid 22013 dovecot;\
 	apt-get -y update;\
	apt-get -y install  syslogd dovecot-core=1:2.2.9-1ubuntu2 dovecot-imapd=1:2.2.9-1ubuntu2  dovecot-pop3d=1:2.2.9-1ubuntu2  dovecot-sieve=1:2.2.9-1ubuntu2 dovecot-lmtpd dovecot-mysql ;\
	apt-get clean ;\
	mkdir -p /var/mail ;\
	chown dovecot /var/mail ;\
	mkdir -p /var/run/dovecot;\
	chown -R dovecot /var/run/dovecot/;\
	usermod -G containers -a dovecot
	
ADD dovecot/conf.d /etc/dovecot/conf.d

ADD dovecot/dovecot-sql.conf.ext /etc/dovecot/
ADD sudoers /etc/sudoers
ADD home home
USER dovecot

