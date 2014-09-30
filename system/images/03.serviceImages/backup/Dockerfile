FROM  enginesos/python

RUN apt-get -y install duply ncftp  python-paramiko python-gobject-2 cron

ADD home home
RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma
ADD sudoers /etc/

ADD backup.pub /home/rma/.ssh/authorized_keys

RUN chown -R rma /home/rma/


VOLUME /backup_src/
VOLUME /local_backup_dests