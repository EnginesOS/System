#!/bin/bash

mongodump  --authenticationDatabase admin --password $dbpasswd -u $dbuser -d  $dbname