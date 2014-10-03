#!/bin/bash
BTICK='`'
EXPECTED_ARGS=3
E_BADARGS=65
PQSQL=` su -l postgres  /usr/bin/perl   /usr/bin/psql `


if [ $# -ne $EXPECTED_ARGS ]
then
echo "Usage: $0 dbname dbuser dbpass"
exit $E_BADARGS
fi

Q1="CREATE DATABASE IF NOT EXISTS ${BTICK}$1${BTICK};"
Q2="GRANT ALL ON ${BTICK}$1${BTICK}.* TO '$2'@'%' IDENTIFIED BY '$3';"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"

#echo "$SQL"

$MYSQL  -urma  -e "$SQL"

