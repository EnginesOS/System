#!/bin/bash



/etc/init.d/ssh start

if test -z $ContUser
        then
                $ContUser=www-data
fi

chown  -R   $ContUser /home/app


