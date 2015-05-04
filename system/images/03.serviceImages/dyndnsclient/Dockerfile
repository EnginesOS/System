FROM ubuntu:14.04 


RUN adduser -q --disabled-password  dyndns;\
	apt-get -y update;\
	apt-get -y install ddclient ;\
	apt-get clean 


COPY home home
COPY dyndns.conf /home/dyndns/

RUN chown dyndns -R /home/dyndns ;\
	chmod og-rw home/dyndns/dyndns.conf;\
	usermod -G containers -a dyndns

ENV ContUser dyndns
ENV ContGrp dyndns
USER dyndns
CMD /home/init.sh