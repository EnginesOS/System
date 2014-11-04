FROM  engines/base

#RUN echo "Y" | adduser -q  --uid 22005 --disabled-password www-data
RUN usermod www-data -u 22005
RUN apt-get -y install nginx
ADD nginx.conf /etc/nginx/
ADD home home

RUN mkdir -p /var/lib/nginx
RUN chown www-data /var/lib/nginx

ENV ContUser www-data
ENV ContGrp www-data
USER www-data

CMD nginx