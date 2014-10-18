FROM  enginesos/servicebase

RUN apt-get -y install mysql-server

ADD home home

RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma
ADD sudoers /etc/

ADD mysql.pub /home/rma/.ssh/authorized_keys
RUN chown -R rma /home/rma/.ssh
RUN chmod -R  700 /home/rma/.ssh

EXPOSE 3306
EXPOSE 22

ENV ContUser mysql
ENV ContGrp mysql


CMD /home/init.sh