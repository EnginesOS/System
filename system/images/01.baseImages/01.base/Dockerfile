#FROM ubuntu:14.04
FROM engines/base_image:alpha 

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y  --force-yes update;\
	apt-get -y  --force-yes upgrade;\
	apt-get -y  --force-yes update;\
	apt-get -y  --fix-missing install   unzip curl dnsutils git  wget bzip2 zlibc sendEmail;\ 
	apt-get clean;\
	mkdir -p /var/run;\
	mkdir -p /etc/apt/apt.conf.d/;\
	dpkg-divert --local --rename --add /sbin/initctl;\
	ln -s /bin/true /sbin/initctl;\
	apt-get clean

ADD init.sh /home/

COPY sendmail /usr/bin/
COPY sendmail /usr/sbin/sendmail

CMD /bin/bash /home/init.sh