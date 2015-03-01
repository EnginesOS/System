#!/bin/bash
PATH="/usr/local/rbenv/bin:$PATH"

#SECRET_KEY_BASE=`/usr/local/rbenv/shims/bundle exec rake secret`
#export SECRET_KEY_BASE 

touch  /engines/var/run/startup_complete
mkdir /var/log/apache2/
/usr/sbin/apache2ctl -D FOREGROUND

rm /var/run/apache2/apache2.pid
rm /engines/var/run/startup_complete
