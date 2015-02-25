FROM engines/base:$release

RUN echo "Y" | adduser -q --disabled-password --home /var/spool/postfix -uid 22003 postfix
RUN apt-get -y update;\
	apt-get -y install postfix syslogd;\
	apt-get clean
ADD home home

ADD postfix/main.cf /etc/postfix/
ADD postfix/master.cf /etc/postfix/
ADD postfix/mailname /etc/mailname
ADD postfix/transport /etc/postfix/
ADD postfix/transport /etc/postfix/transport.no_smarthost
ADD postmap /etc/postfix/transport
   
ENV ContUser postfix
ENV ContGrp postfix

CMD /home/init.sh