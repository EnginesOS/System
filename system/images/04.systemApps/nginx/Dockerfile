FROM  enginesos/base
RUN apt-get -y install nginx
RUN apt-get -y install telnet
RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma
ADD sudoers /etc/
RUN chown 0 /etc/sudoers

ADD ngnix.pub /home/rma/.ssh/authorized_keys
RUN chown -R rma /home/rma/.ssh


ADD home home

#ADD publify /etc/nginx/sites-enabled/publify
#ADD phpmyadmin /etc/nginx/sites-enabled/phpmyadmin

EXPOSE 80
EXPOSE 443
EXPOSE 22
