FROM  engines/apache


RUN echo "Y" | adduser -q --disabled-password -uid 22011 courier ;\
 	mkdir -p /var/run/courier/authdaemon;\
 	mkdir -p /usr/lib/courier/etc/webadmin/;\
 	echo firstpasswd > /usr/lib/courier/etc/webadmin/password;\ 	
 	apt-get -y install libmysqlclient-dev courier-imap-ssl  courier-authlib-mysql courier-pop-ssl courier-ssl courier-webadmin couriergrey ;\
 	/usr/sbin/makealiases;\
 	ln -s 
 #/usr/lib/courier/libexec/courier/webmail/webadmin nah use apache alias
 # apt-get -y sqwebmail;\	
ADD  000-default.conf/etc/apache2/sites-enabled/	
 	

ENV ContUser courier
ENV ContGrp courier


CMD /home/init.sh