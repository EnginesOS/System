FROM  engines/base

#RUN echo "Y" | adduser -q  --uid 22005 --disabled-password www-data
RUN usermod www-data -u 22005
RUN apt-get -y install nginx
ADD nginx.conf /etc/nginx/
ADD home home


EXPOSE 80
EXPOSE 443


ENV ContUser www-data
ENV ContGrp www-data
UESR www-data
CMD nginx