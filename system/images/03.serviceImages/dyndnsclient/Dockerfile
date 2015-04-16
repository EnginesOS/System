FROM ubuntu:14.04 


RUN adduser -q --disabled-password  dyndns;\
	apt-get -y update;\
	apt-get -y install ddclient ;\
	apt-get clean;\
    
USER backup

COPY home home

ENV ContUser dyndns
ENV ContGrp dyndns

CMD /home/init.sh