#!/bin/bash


 wget http://pear.php.net/go-pear.phar
 suhosin.executor.include.whitelist = phar >>/etc/php5/conf.d/suhosin.ini 
   php go-pear.phar
    for mod in $*
     do
     mod=`echo $mod | sed "/[;&]/s///g"`
     pecl install $mod
     done
   rm go-pear.phar
  
