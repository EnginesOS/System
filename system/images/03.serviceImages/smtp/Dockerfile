FROM enginesos/base


RUN apt-get -y  --force-yes update

RUN apt-get -y install postfix

ADD home home

ADD postfix/main.cf /etc/postfix/
ADD postfix/mailname /etc/mailname