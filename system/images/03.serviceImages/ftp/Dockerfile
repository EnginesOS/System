FROM engines/base

RUN apt-get -y update
RUN  apt-get -y install proftpd proftpd-mod-mysql
ADD proftpd.conf /etc/proftpd/
ADD tls.conf /etc/proftpd/
ADD sql.conf /etc/proftpd/