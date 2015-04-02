FROM  engines/base:$release


RUN usermod www-data -u 22005;\
	apt-get -y update;\
	apt-get -y install nginx;\
	apt-get clean;\
	mkdir -p /var/lib/nginx /var/run/nginx/ ;\ 
	chown www-data /var/lib/nginx /var/run/nginx/

ADD nginx.conf /etc/nginx/
ADD home home
ADD templates /etc/nginx

ENV ContUser www-data
ENV ContGrp www-data

USER 22005

CMD nginx