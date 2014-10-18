FROM enginesos/servicebase


RUN apt-get -y install postfix syslogd

ADD home home
ADD syslog.conf /etc/
ADD postfix/main.cf /etc/postfix/
ADD postfix/master.cf /etc/postfix/
ADD postfix/mailname /etc/mailname

ENV ContUser postfix
ENV ContGrp postfix
