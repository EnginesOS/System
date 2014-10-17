FROM  enginesos/python

RUN apt-get -y install duply ncftp  python-paramiko python-gobject-2 cron

ADD etc  etc
ADD home home
RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma


ADD backup.pub //home/rma/.ssh/authorized_keys
ADD crontab  /var/spool/cron/crontabs/root
RUN chown -R rma ~rma 
RUN chmod 700 ~rma/.ssh 


VOLUME /backup_src/volumes
VOLUME /backup_src/engos
VOLUME /local_backup_dests

ENV ContUser root
ENV ContGrp wheel
