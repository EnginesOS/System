FROM engines/frameworkbuild
 
 
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7 ;\
   	apt-get install apt-transport-https ca-certificates;\
    echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main  >/etc/apt/sources.list.d/passenger.list;\ 
    chmod 600 /etc/apt/sources.list.d/passenger.list;\
    apt-get install apache2 libapache2-mod-passenger;\
    a2enmod passenger;\
    
