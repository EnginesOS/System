FROM  engines/apache

RUN echo "Y" | adduser -q --disabled-password -uid 22011 courier

RUN apt-get -y install courier-imap-ssl  courier-authlib-mysql courier-pop-ssl courier-ssl courier-webadmin couriergrey sqwebmail

ADD home home

ENV ContUser courier
ENV ContGrp courier


CMD /home/init.sh