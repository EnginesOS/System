FROM  engines/base

#RUN echo "Y" | adduser -q  --uid 22005 --disabled-password www-data
RUN usermod www-data -u 22005;\
	apt-get -y update;\
	apt-get -y install nginx;\
	apt-get clean
ADD nginx.conf /etc/nginx/
ADD home home

RUN mkdir -p /var/lib/nginx /var/run/nginx/ 
RUN chown www-data /var/lib/nginx /var/run/nginx/

ENV ContUser www-data
ENV ContGrp www-data
USER www-data

CMD nginx