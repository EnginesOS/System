
FROM debian:wheezy

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install bind9

RUN mkdir -p /var/lib/bind/engines
RUN chown bind /var/lib/bind/engines
ADD named.conf.default-zones.ad /etc/
RUN cat /etc/named.conf.default-zones.ad >> /etc/bind/named.conf.default-zones
ADD engines.local.domain /var/lib/bind/engines/engines.dnsrecords
