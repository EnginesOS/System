#!/bin/bash
 rm -f /run/apache2/apache2.pid 
 /usr/lib/courier/courierctl.start
 
 /usr/sbin/apache2ctl -D FOREGROUND 
 rm -f /run/apache2/apache2.pid 