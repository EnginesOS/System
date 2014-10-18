FROM  enginesos/servicebase

RUN apt-get -y install postgresql 
ADD home home
RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma
ADD sudoers /etc/

ADD pgsql.pub /home/rma/.ssh/authorized_keys
RUN chown -R rma /home/rma/.ssh
RUN chmod -R  700 /home/rma/.ssh
RUN mv /var/lib/postgresql /var/lib/postgresql_firstrun

EXPOSE 3306
EXPOSE 22

ENV ContUser postgres
ENV ContGrp  postgres

