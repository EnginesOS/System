FROM engines/rails4

RUN apt-get update -y
RUN /usr/sbin/usermod -u 22671 www-data
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN	apt-get install -y apt-transport-https ca-certificates  apache2-threaded-dev libapr1-dev libaprutil1-dev
RUN echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main  >/etc/apt/sources.list.d/passenger.list 
RUN chmod 600 /etc/apt/sources.list.d/passenger.list
RUN apt-get install -y apache2 libapache2-mod-passenger
RUN a2enmod passenger
RUN rm etc/apache2/sites-enabled/*
ADD 000-default.conf /etc/apache2/sites-enabled/

RUN chmod -R g+w /usr/local/rbenv/versions/ ;chgrp -R www-data /usr/local/rbenv/versions/
RUN chown -R www-data /usr/local/rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/extensions

RUN /usr/local/rbenv/shims/gem install passenger
RUN /usr/local/rbenv/shims/passenger-install-apache2-module -a --languages ruby,nodejs,python
ADD ports.conf /etc/apache2/

RUN mkdir /home/app ; chown  www-data /home/app
RUN mkdir -p /var/log/apache2 ; chown -R www-data /var/log/apache2
ENV ContUser www-data
ENV ContGrp www-data

USER www-data