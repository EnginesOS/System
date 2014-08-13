#!/bin/sh
/etc/init.d/apache2 start

check=`/etc/init.d/apache2 status`

while test -z `echo $check |grep -i NOT`
        do

        sleep 10
        check=`/etc/init.d/apache2 status`


        done

