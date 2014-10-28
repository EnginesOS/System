FROM  enginesos/servicebase
RUN echo "Y" | adduser -q --disabled-password --home /var/cache/bind -uid 22009 bind

RUN apt-get -y install bind9

RUN mkdir -p /var/lib/bind/engines
RUN mkdir -p /var/run/named

ADD named.conf.local /etc/bind/named.conf.local
ADD named.conf.default-zones.ad /etc/

RUN cat /etc/named.conf.default-zones.ad >> /etc/bind/named.conf.default-zones
ADD engines.internal.domain /var/lib/bind/engines/engines.dnsrecords

RUN chown bind /var/run/named
RUN chown bind /var/lib/bind/engines


COPY home home

#CMD /usr/sbin/named -c /etc/bind/named.conf -u bind -g

ENV ContUser bind
ENV ContGrp bind

CMD /home/init.sh