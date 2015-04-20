FROM  engines/servicebase:$release


RUN echo "Y" |/usr/sbin/usermod -u  22012 syslog ;\
 	apt-get -y update;\
 	apt-get -y install syslog-ng-core syslog-ng ;\
 	apt-get clean ;\
 	mkdir -p /home/rlog/;\
 	chown syslog /var/lib/syslog-ng/ 
#


		 

ENV ContUser syslog
ENV ContGrp syslog
ADD syslog-ng.conf /etc/syslog-ng/
ADD custom_start.sh /home/engines/scripts/
CMD /home/init.sh
USER syslog