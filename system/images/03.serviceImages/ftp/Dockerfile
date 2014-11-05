FROM engines/base
RUN echo "Y"| adduser --uid 22010 -q --home /home/ftpd --disabled-password proftpd
RUN apt-get -y update
RUN  apt-get -y install proftpd proftpd-mod-mysql
ADD proftpd.conf /etc/proftpd/
ADD tls.conf /etc/proftpd/
ADD sql.conf /etc/proftpd/
ADD modules.conf /etc/proftpd/
RUN mkdir /ftp/