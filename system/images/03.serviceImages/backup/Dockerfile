FROM  TAG

RUN apt-get -y install duply

ADD home home
RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma
ADD sudoers /etc/

ADD mysql.pub /home/rma/.ssh/authorized_keys
RUN chown -R rma /home/rma/.ssh
