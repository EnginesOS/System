From engines/base
RUN echo "Y" | adduser -q --disabled-password  -uid 22001 dovecot
RUN apt-get -y update;\
	apt-get -y install  syslogd dovecot-core dovecot-imapd  dovecot-pop3d  dovecot-sieve dovecot-lmtpd dovecot-mysql ;\
	apt-get clean
ADD home home
ADD syslog.conf /etc/