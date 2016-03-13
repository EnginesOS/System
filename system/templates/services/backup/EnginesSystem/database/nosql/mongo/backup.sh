#!/bin/bash
cd /tmp
mongodump  -h mongo --password $dbpasswd -u $dbuser -d  $dbname
tar -cpf - dump
rm -r dump