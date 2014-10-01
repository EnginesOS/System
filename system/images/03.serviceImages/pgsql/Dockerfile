FROM  enginesos/base
RUN apt-get -y install postgresql 
ADD home home
RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma
ADD sudoers /etc/

ADD pgsql.pub /home/rma/.ssh/authorized_keys
RUN chown -R rma /home/rma/.ssh

EXPOSE 3306
EXPOSE 22
