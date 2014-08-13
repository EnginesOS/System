#!/bin/bash
cd /home/app
gem  install rake
gem install vmstat
/etc/init.d/ssh start

#git pull
#bundle install
if test -z $ContUser
        then
                $ContUser=www-data
fi

chown  -R   $ContUser .

