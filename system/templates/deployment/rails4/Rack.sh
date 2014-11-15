#!/bin/bash
PATH="/usr/local/rbenv/bin:$PATH"

cd /home/app



if test -f /home/pre-running.sh
	then
		bash	/home/pre-running.sh
fi

if test -n "$CRONJOBS"
then
	service cron start
fi

#in Dockerfile
#RAILS_ENV=production
#DATABASE_URL=mysql2://$dbuser:$dbpasswd@$dbhost/$dbname
#export  RAILS_ENV DATABASE_URL

#/usr/local/rbenv/shims/bundle install

#/usr/local/rbenv/shims/bundle exec rake db:migrate

#/usr/local/rbenv/shims/bundle exec rake db:populate

#/usr/local/rbenv/shims/bundle exec rake assets:precompile


SECRET_KEY_BASE=`/usr/local/rbenv/shims/bundle exec rake secret`
export SECRET_KEY_BASE 

touch  /engines/var/run/startup_complete
mkdir /var/log/apache2/
/usr/sbin/apache2ctl -D FOREGROUND

rm /var/run/apache2/apache2.pid
rm /engines/var/run/startup_complete
