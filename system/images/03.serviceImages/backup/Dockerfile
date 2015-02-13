FROM  engines/python

RUN apt-get -y update;\
	apt-get -y install sudo vim  openssh-server duply ncftp  python-paramiko python-gobject-2 cron;\
	apt-get clean 
ADD etc  etc
ADD home home
RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma



ADD crontab  /var/spool/cron/crontabs/root
RUN chown -R rma ~rma 
#RUN chmod 700 ~rma/.ssh 


VOLUME /backup_src/volumes
VOLUME /backup_src/engines
VOLUME /local_backup_dests

ENV ContUser root
ENV ContGrp wheel
