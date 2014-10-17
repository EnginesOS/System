#!/bin/bash

~/.rbenv/shims/gem install git bundle oink
~/.rbenv/shims/gem install vmstat


/etc/init.d/ssh start

if test -z $ContUser
        then
                $ContUser=www-data
fi

chown  -R   $ContUser /home/app


