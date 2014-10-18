FROM  enginesos/servicebase

RUN apt-get -y install nginx
RUN apt-get -y install telnet
RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma
ADD sudoers /etc/
RUN chown 0 /etc/sudoers

ADD home home

ADD default /etc/nginx/sites-available/default

ADD nginx.pub /home/rma/.ssh/authorized_keys
RUN chown -R rma /home/rma/.ssh
RUN chmod -R  700 /home/rma/.ssh

EXPOSE 80
EXPOSE 443
EXPOSE 22

ENV ContUser www-data
ENV ContGrp www-data

CMD /home/init.sh