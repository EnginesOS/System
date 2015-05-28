#!/bin/sh
rm -f /engines/var/run/startup_complete


PIDFILE=/var/run/named/named.pid
source /home/trap.sh

mkdir -p /var/run/named
chown -R bind /var/run/named
mkdir -p /var/log/named
chown -R bind /var/log/named

cd /tmp
/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 128 -n HOST  -r /dev/urandom -n HOST DDNS_UPDATE
mv *private /etc/bind/keys/ddns.private
mv *key /etc/bind/keys/ddns.key
key=`cat /etc/bind/keys/ddns.private |grep Key | cut -f2 -d" "`
cp /etc/bind/templates/named.conf.default-zones.start /etc/bind/named.conf.default-zones;\
echo "secret \"$key\";" >> /etc/bind/named.conf.default-zones;\
cat /etc/bind/templates/named.conf.default-zones.end >> /etc/bind/named.conf.default-zones


exec /usr/sbin/named -f -c /etc/bind/named.conf -u bind 

mkdir -p /engines/var/run/
touch  /engines/var/run/startup_complete
chown 21000 /engines/var/run/startup_complete

sleep 30

while test -f /var/run/named/named.pid
	do
	  sleep 120
	done

rm /engines/var/run/startup_complete
