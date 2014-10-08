FROM  enginesos/base

RUN apt-get update
RUN apt-get install -y apache2 libapache2-mod-php5 php5-mysql php5-mcrypt  php5-gd
ADD home home
ADD 30-sendmail.ini /etc/php5/apache2/conf.d/
ADD 000-default.conf etc/apache2/sites-enabled/
#ADD apache2.conf etc/apache2/
EXPOSE 80
