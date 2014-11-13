#!/bin/bash
PATH="/usr/local/rbenv/bin:$PATH"

cd /home/app
rm /home/app/app/config/newrelic.yml
git pull
cp /home/newrelic.yml /home/app/

RAILS_ENV=production


export  RAILS_ENV

/usr/local/rbenv/shims/bundle install

/usr/local/rbenv/shims/bundle exec rake db:migrate

/usr/local/rbenv/shims/bundle exec rake db:populate

/usr/local/rbenv/shims/bundle exec rake assets:precompile

SECRET_KEY_BASE=`/usr/local/rbenv/shims/bundle exec rake secret`
export SECRET_KEY_BASE RAILS_ENV

touch  /engines/var/run/startup_complete

/usr/sbin/apache2ctl -D FOREGROUND

rm /var/run/apache2/apache2.pid
rm /engines/var/run/startup_complete
