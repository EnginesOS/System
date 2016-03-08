#!/bin/bash

mysqldump -h $dbhost -u $dbuser --password=$dbpasswd $dbname 