FROM  engines/apache


RUN echo "Y" | adduser -q --disabled-password -uid 22012 syslog ;\
	curl http://packages.madhouse-project.org/debian/archive-key.txt |  apt-key add -;\
	echo "deb       http://packages.madhouse-project.org/ubuntu   trusty   syslog-ng-3.5 syslog-ng-incubator-3.5" > /etc/apt/sources.list.d/syslog-ng.list;\
 	apt-get -y update;\
 	apt-get -y install syslog-ng-core syslog-ng ;\
 	apt-get clean 
#


		 

ENV ContUser syslog
ENV ContGrp syslog
ADD syslog-ng.conf /etc/syslog-ng/
ADD custom_start.sh /home/engines/scripts/
CMD /home/init.sh