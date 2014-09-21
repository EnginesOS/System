#!/bin/bash
 . /etc/rvmrc 

gem install git
rvm gemset create bundle
rvm gemset create git

su -l $ContUser /opt/engos/bin/containers_startup.sh 

gem  install rake
rvm gemset create rake
gem install vmstat
rvm gemset create  vmstat

/etc/init.d/ssh start

if test -z $ContUser
        then
                $ContUser=www-data
fi


chown  -R   $ContUser /home/app


