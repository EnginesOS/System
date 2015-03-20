FROM engines/base:$release
Maintainer image.maintainer@engines.onl
RUN echo "Y" | adduser -q --disabled-password --home /var/spool/postfix -uid 22003 postfix
RUN apt-get -y update;\
	apt-get -y install postfix syslogd;\
	apt-get clean
ADD home home

ADD postfix/main.cf /etc/postfix/
ADD postfix/master.cf /etc/postfix/
RUN chown postfix /etc/postfix/


   
ENV ContUser postfix
ENV ContGrp postfix

CMD /home/init.sh