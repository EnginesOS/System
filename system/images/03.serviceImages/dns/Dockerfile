
FROM debian:wheezy

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install bind9

RUN mkdir -p /var/lib/bind/engines
RUN chown bind /var/lib/bind/engines

RUN echo "key DDNS_UPDATE {
algorithm HMAC-MD5.SIG-ALG.REG.INT;
secret \"lP4oC8uGZ713YYQjjZET+A==\";
};

zone \"engines.local\" {
type master;
file \"/var/lib/bind/engines/engines.dnsrecords\";
allow-update { key DDNS_UPDATE; };

}; " >> /etc/bind/named.conf.default-zones

RUN  echo "\$ORIGIN .
\$TTL 604800 ; 1 week
engines.local IN SOA engines. root.engines. (
999 ; serial
604800 ; refresh (1 week)
86400 ; retry (1 day)
2419200 ; expire (4 weeks)
604800 ; minimum (1 week)
)
NS 127.0.0.1
A 127.0.0.1
AAAA ::1
\$ORIGIN engines.local. " >/var/lib/bind/engines/engines.dnsrecords
