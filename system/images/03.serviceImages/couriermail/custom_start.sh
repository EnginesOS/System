#!/bin/bash
rm -f /run/apache2/apache2.pid 
/etc/init.d/rsyslog start
/usr/lib/courier/courierctl.start
/usr/sbin/esmtpd start
/usr/sbin/imapd-ssl start
/usr/sbin/imapd start
/usr/sbin/pop3d start
/usr/sbin/pop3d-ssl start
/usr/sbin/apache2ctl -D FOREGROUND 
rm -f /run/apache2/apache2.pid 