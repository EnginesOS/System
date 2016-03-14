#!/bin/bash
cat - |gzip -d | mysql -h $dbhost -u $dbuser --password $dbpasswd $dbname

