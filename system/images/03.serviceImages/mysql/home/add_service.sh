#!/bin/bash

service_hash=$1

. /home/engines/scripts/functions.sh

load_service_hash_to_environment

BTICK='`'

E_BADARGS=65
MYSQL=`which mysql`

if test -z $database_name
	then
		echo Error:No database_name value
		exit -1
	fi
	
if test -z $db_username
	then
		echo Error:No db_username value
		exit -1
	fi
		
if test -z $db_password
	then
		echo Error:No db_password value
		exit -1
	fi
	
if test -z $collation
	then
		echo Error:No collation value
		exit -1
	fi
	

Q1="CREATE DATABASE IF NOT EXISTS ${BTICK}$database_name${BTICK}   DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE $collation ;"
Q2="GRANT ALL ON ${BTICK}$database_name${BTICK}.* TO '$db_username'@'%' IDENTIFIED BY '$db_password';"
Q3="Grant Create User on *.* to '$db_username'@'%';"
Q4="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}${Q4}"

#echo "$SQL"

$MYSQL   -urma  -e "$SQL"

if test $? -ge 0
	then 
		echo "Success"
		exit 0
	fi
	
	echo "Error:"
	exit -1

