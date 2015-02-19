From engines/base
RUN echo "Y" | adduser -q --disabled-password  -uid 22001 cyrus
RUN apt-get -y update;\
	apt-get -y install  syslogd   cyrus-admin cyrus-clients cyrus-imapd sasl2-bin;\
	apt-get clean
ADD home home
ADD syslog.conf /etc/