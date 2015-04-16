FROM ubuntu:14.04 


RUN adduser -q --disabled-password  dyndns;\
	apt-get -y update;\
	apt-get -y install ddclient ;\
	apt-get clean 
    
USER dyndns

COPY home home
COPY dyndns.conf /home/dyndns/

ENV ContUser dyndns
ENV ContGrp dyndns

CMD /home/init.sh