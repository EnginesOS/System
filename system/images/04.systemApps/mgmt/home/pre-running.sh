#!/bin/bash

gem install bundle

cd  /opt/engos/bin/

su -l $ContUser bundle install

su -l $ContUser bundle exec /opt/engos/bin/containers_startup.sh & #Background 


gem  install rake

gem install vmstat

/etc/init.d/ssh start

if test -z $ContUser
        then
                $ContUser=www-data
fi


chown  -R   $ContUser /home/app


