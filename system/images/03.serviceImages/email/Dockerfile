FROM engines/php:$release

RUN echo "Y" | adduser -q --disabled-password --home /var/spool/postfix -uid 22003 postfix
RUN apt-get -y update;\
	apt-get -y install postfix syslogd  php5-imap postfix-mysql postgrey;\
	apt-get clean
ADD home home

ADD postfix/main.cf /etc/postfix/
ADD postfix/master.cf /etc/postfix/
ADD postfix/mailname /etc/mailname
ADD postfix/mysql /etc/postfix/mysql
ADD postgrey /etc/default/postgrey

RUN cd /tmp/;\
	 wget http://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-2.92/postfixadmin-2.92.tar.gz;\
	 tar -xzpf postfixadmin-2.92.tar.gz;\
	 mv  postfixadmin-2.92 /home/app ;\
	 mkdir /var/log/apache2;\
	 chown www-user /var/log/apache2 ;\
	 ln -s /etc/php5/mods-available/imap.ini /etc/php5/apache2/conf.d/;\
	 chgrp www-data /home/app/templates_c/;\
	  chmod g+w /home/app/templates_c;\
	  usermod -G containers -a postfix
	 
	 
	 
ADD config.inc.php  /home/app/
	 
	
	

ENV ContUser postfix
ENV ContGrp postfix

CMD /home/init.sh