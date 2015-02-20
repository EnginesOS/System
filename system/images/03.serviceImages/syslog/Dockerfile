FROM  engines/apache


RUN echo "Y" |/usr/sbin/usermod -u  22012 syslog ;\
	curl http://packages.madhouse-project.org/debian/archive-key.txt |  apt-key add -;\
	echo "deb       http://packages.madhouse-project.org/ubuntu   trusty   syslog-ng-3.5 syslog-ng-incubator-3.5" > /etc/apt/sources.list.d/syslog-ng.list;\
 	apt-get -y update;\
 	apt-get -y install syslog-ng-core syslog-ng ;\
 	apt-get clean ;\
 	mkdir -p /home/rlog/;\
 	chown syslog /home/rlog/;\
 	chown syslog /var/lib/syslog-ng/ 
#


		 

ENV ContUser syslog
ENV ContGrp syslog
ADD syslog-ng.conf /etc/syslog-ng/
ADD custom_start.sh /home/engines/scripts/
CMD /home/init.sh
USER syslog