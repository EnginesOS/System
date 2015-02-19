FROM engines/php

RUN echo "Y" | adduser -q --disabled-password --home /var/spool/postfix -uid 22003 postfix
RUN apt-get -y update;\
	apt-get -y install postfix syslogd;\
	apt-get clean
ADD home home
ADD syslog.conf /etc/
ADD postfix/main.cf /etc/postfix/
ADD postfix/master.cf /etc/postfix/
ADD postfix/mailname /etc/mailname

RUN cd /tmp/;\
	 wget http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-2.92/postfixadmin-2.92.tar.gz;\
	 tar -xzpf postfixadmin-2.92.tar.gz;\
	 mv  postfixadmin-2.92 /home/app 
	 
ADD config.inc.php  /home/app
	 
	
	

ENV ContUser postfix
ENV ContGrp postfix

CMD /home/init.sh