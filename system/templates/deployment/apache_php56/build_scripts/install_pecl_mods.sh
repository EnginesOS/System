#!/bin/sh

#could be dynamic

 wget http://pear.php.net/go-pear.phar
 echo  suhosin.executor.include.whitelist = phar >>/etc/php/7.0/conf.d/suhosin.ini 
   php go-pear.phar
    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     pecl install $mod
     done
   rm go-pear.phar
  
