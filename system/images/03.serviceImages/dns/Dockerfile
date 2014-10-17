FROM  enginesos/base

RUN apt-get -y  --force-yes update
#RUN apt-get -y  --force-yes upgrade
RUN apt-get -y install bind9

RUN mkdir -p /var/lib/bind/engines
RUN mkdir -p /var/run/named

ADD named.conf.local /etc/bind/named.conf.local
ADD named.conf.default-zones.ad /etc/
ADD named.conf.logging /etc/bind/named.conf.logging
RUN cat /etc/named.conf.default-zones.ad >> /etc/bind/named.conf.default-zones
ADD engines.local.domain /var/lib/bind/engines/engines.dnsrecords

RUN chown bind /var/run/named
RUN chown bind /var/lib/bind/engines


ADD home home

CMD /usr/sbin/named -c /etc/bind/named.conf -u bind -g

ENV ContUser bind
ENV ContGrp bind
