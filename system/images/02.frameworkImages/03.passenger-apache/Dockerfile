FROM engines/frameworkbuild
 
 
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN	apt-get install -y apt-transport-https ca-certificates
RUN echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main  >/etc/apt/sources.list.d/passenger.list 
RUN chmod 600 /etc/apt/sources.list.d/passenger.list
RUN apt-get install -y apache2 libapache2-mod-passenger
RUN a2enmod passenger
    
