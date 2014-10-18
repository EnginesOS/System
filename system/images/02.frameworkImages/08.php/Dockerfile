FROM enginesos/frameworkbase


RUN apt-get install -y  apache2 libapache2-mod-php5 php5-mysql php5-mcrypt  php5-gd
ADD home home
ADD 30-sendmail.ini /etc/php5/apache2/conf.d/
RUN rm etc/apache2/sites-enabled/*
ADD 000-default.conf /etc/apache2/sites-enabled/

EXPOSE 80

ENV ContUser www-data
ENV ContGrp www-data