FROM  engines/python:$release

RUN apt-get -y update;\
	apt-get -y install vim  duply ncftp  python-paramiko python-gobject-2  ;\
	apt-get clean 
ADD etc  etc
ADD home home
RUN echo "Y" | /usr/sbin/usermod -u 22015 -d /home/backup  backup;\
	cd /tmp; \
  	wget ftp://ftp.seul.org/pub/fcron/fcron-3.2.0.src.tar.gz;\
  	tar -xzpf fcron-3.2.0.src.tar.gz;\
  	cd fcron-3.2.0;\
  	./configure --with-run-non-privileged --with-rootname=backup\
  	 --without-sendmail\
	--with-rootgroup=backup --with-username=backup --with-groupname=backup\
	--with-etcdir=/home/backup/fcron --with-piddir=/home/backup/fcron\
	--with-fifodir=/home/backup/fcron --with-spooldir=/home/backup/fcron/spool\
	--with-docdir=/home/backup/fcron/doc --prefix=/home/backup/fcron;\
	make install;\
	mkdir -p /home/backup/fcron/doc/home/backup/fcron/man,/home/backup/fcron/spool};\
	cd /home/backup;\
	rm -r /tmp/fcron-3.2.0 ;\
	rm /tmp/fcron-3.2.0.src.tar.gz;\
	mkdir -p /var/log/backup/
	chown -R backup /etc/duply/ /var/log/backup/



ADD crontab  /var/spool/cron/crontabs/backup
RUN chown -R backup ~backup 
#RUN chmod 700 ~rma/.ssh 


VOLUME /backup_src/volumes
VOLUME /backup_src/engines
VOLUME /local_backup_dests

USER backup
ENV ContUser backup
ENV ContGrp backup
