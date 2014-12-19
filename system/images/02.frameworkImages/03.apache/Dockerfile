FROM engines/frameworkbase

RUN /usr/sbin/usermod -u 22671 www-data;\
	apt-get update -y;\
	apt-get install -y  apache2 ;\
	rm etc/apache2/sites-enabled/*;\
	mkdir -p /etc/apache2/ /var/run/apache2;\
	chown www-data /var/run/apache2	



ADD 000-default.conf /etc/apache2/sites-enabled/
ADD ports.conf /etc/apache2/

ENV ContUser www-data
ENV ContGrp www-data