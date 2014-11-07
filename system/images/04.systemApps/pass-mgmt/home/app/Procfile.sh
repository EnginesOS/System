#!/bin/bash
PATH="/usr/local/rbenv/bin:$PATH"

cd /home/app
cp /home/gitconfig /home/app/.git/config
git pull

RAILS_ENV=prodution

SECRET_KEY_BASE=`/usr/local/rbenv/shims/bundle exec rake secret`
export SECRET_KEY_BASE RAILS_ENV

/usr/local/rbenv/shims/bundle install

/usr/local/rbenv/shims/bundle exec rake db:migrate

/usr/local/rbenv/shims/bundle exec rake db:populate

/usr/local/rbenv/shims/bundle exec rake assets:precompile


touch  /engines/var/run/startup_complete

/usr/sbin/apache2ctl -D FOREGROUND
rm /engines/var/run/startup_complete
