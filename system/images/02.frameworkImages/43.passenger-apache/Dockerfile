FROM engines/ruby2.1.2

RUN apt-get update -y
RUN /usr/sbin/usermod -u 2671 www-data
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN	apt-get install -y apt-transport-https ca-certificates
RUN echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main  >/etc/apt/sources.list.d/passenger.list 
RUN chmod 600 /etc/apt/sources.list.d/passenger.list
RUN apt-get install -y apache2 libapache2-mod-passenger
RUN a2enmod passenger
RUN chmod -R g+w /usr/local/rbenv/versions/ ;chgrp -R www-data /usr/local/rbenv/versions/
RUN /usr/local/rbenv/shims/gem install passenger
RUN passenger-install-apache2-module
ADD ports.conf /etc/apache2/
USER www-data