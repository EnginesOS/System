FROM  engines/passenger

RUN /usr/sbin/addgroup --gid 999 docker;\
	echo "Y" | adduser -q --uid 21000 --gid 999 --home /home/dockuser --disabled-password dockuser

ADD home home
ADD profile /home/dockuser/.profile


ENV ContUser dockuser
ENV ContGrp ruby

#need to create as linking sqllite
RUN mkdir -p /home/app/app/db
RUN chown dockuser /home/app/app/db

WORKDIR /home/app/
RUN	git init

ADD gitconfig /home/app/.git/config

RUN /usr/local/rbenv/shims/gem install git bundle oink vmstat;\	
	chown -R 21000 /home/app/ /home/dockuser /var/log/apache2/;\
	chmod -R g+w /usr/local/rbenv/versions/ ;chgrp -R docker /usr/local/rbenv/versions/;\
	chown -R 21000 /usr/local/rbenv/versions/$ruby_version/lib/ruby/gems/2.1.0/extensions;\
	mkdir -p  /run/apache2;\
	chown -R 21000 /run/apache2;\
 	mkdir -p /run/lock/apache2 ;\
 	a2enmod ssl;\
 	chown 21000 /run/lock/apache2

#After after chmod so not rewritable

ADD 000-default.conf /etc/apache2/sites-enabled/
ADD SSL-default.conf /etc/apache2/sites-enabled/
ADD Procfile.sh /home/app/

CMD /home/app/Procfile.sh
USER 21000
