#!/bin/sh
if test -z $PHP_VERSION
 then
   PHP_VERSION=7.2
fi
 wget http://pear.php.net/go-pear.phar

echo suhosin.executor.include.whitelist = phar >>/etc/php/$PHP_VERSION/cli/conf.d/suhosin.ini 

   php go-pear.phar
    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     pear install $mod
     done
   rm go-pear.phar
  
