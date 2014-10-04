FROM  enginesos/base
RUN apt-get -y install nginx
RUN apt-get -y install telnet
RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma
ADD sudoers /etc/
RUN chown 0 /etc/sudoers

ADD home home

ADD nginx.pub /home/rma/.ssh/authorized_keys
RUN chown -R rma /home/rma/.ssh
RUN chmod -R  700 /home/rma/.ssh

ADD default /etc/nginx/sites-available/default

EXPOSE 80
EXPOSE 443
EXPOSE 22

#docker run -h nginx --memory=64m  -v /etc/localtime:/etc/localtime:ro  -v /opt/engos/etc/ssl/://etc/nginx/ssl/: -v /var/log/engos/services/nginx/://var/log/: -p 22/tcp  -p 443:443/tcp  -p 80:80/tcp  --cidfile /opt/engos/run/nginx.cid --name nginx -i  -t enginesos/nginx /bin/bash 