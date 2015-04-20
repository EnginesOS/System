FROM ubuntu:14.04 

ADD sources.list /etc/apt/

RUN apt-get -y  --force-yes update;\
	apt-get -y  --force-yes upgrade;\
	apt-get -y  --force-yes update;\
	apt-get -y  --fix-missing install   unzip curl dnsutils git  wget bzip2 zlibc sendEmail;\ 
	apt-get clean;\
	mkdir -p /var/run;\
	mkdir -p /etc/apt/apt.conf.d/;\
	apt-get clean
#	echo "Acquire::http::Proxy \"http://172.17.42.1:3142\";" >/etc/apt/apt.conf.d/01proxy
	

#ADD ddns.key /etc/
#ADD ddns.private /etc/
#ADD dns-init.sh /home/
ADD init.sh /home/

COPY sendmail /usr/bin/
COPY sendmail /usr/sbin/sendmail

CMD /bin/bash /home/init.sh