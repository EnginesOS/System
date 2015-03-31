#!/bin/bash
BTICK='`'
EXPECTED_ARGS=2
E_BADARGS=65
MYSQL=`which mysql`


if [ $# -ne $EXPECTED_ARGS ]
then
echo "Usage: $0 dbname dbuser dbpass"
exit $E_BADARGS
fi

Q1="Drop DATABASE  ${BTICK}$1${BTICK}   ;"
Q2="DELETE FROM user where user='$2'@'%';"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"

#echo "$SQL"

$MYSQL   -urma  -e "$SQL"