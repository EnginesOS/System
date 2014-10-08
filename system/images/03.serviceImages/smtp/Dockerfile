FROM enginesos/base


RUN apt-get -y  --force-yes update

RUN apt-get -y install postfix syslogd

ADD home home
ADD syslog.conf /etc/
ADD postfix/main.cf /etc/postfix/
ADD postfix/mailname /etc/mailname