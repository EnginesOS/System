#!/bin/bash
mysqldump -h $dbhost -u $dbuser --password $dbpasswd  --all-databases > /home/sql_dumps/alldatabases.sql 