FROM  engines/servicebase

RUN echo "Y" | adduser -q --disabled-password -uid 22011 courier

RUN apt-get -y install courier-imap-ssl

ADD home home

ENV ContUser courier
ENV ContGrp courier


CMD /home/init.sh