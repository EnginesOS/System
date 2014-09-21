#!/bin/bash

gem install bundle
gem install git
rvm gemset create bundle
rvm gemset create git

su -l $ContUser /opt/engos/bin/containers_startup.sh 

gem  install rake

gem install vmstat

/etc/init.d/ssh start

if test -z $ContUser
        then
                $ContUser=www-data
fi


chown  -R   $ContUser /home/app


