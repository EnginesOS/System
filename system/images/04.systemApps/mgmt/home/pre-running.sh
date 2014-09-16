#!/bin/bash
gem install git

su -l $ContUser /opt/engos/bin/containers_startup.sh & #Background 


gem  install rake

gem install vmstat

/etc/init.d/ssh start

if test -z $ContUser
        then
                $ContUser=www-data
fi


chown  -R   $ContUser /home/app


