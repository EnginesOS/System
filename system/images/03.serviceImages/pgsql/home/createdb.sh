#!/bin/bash
BTICK='`'
EXPECTED_ARGS=3
E_BADARGS=65
MYSQL=`which mysql`


if [ $# -ne $EXPECTED_ARGS ]
then
echo "Usage: $0 dbname dbuser dbpass"
exit $E_BADARGS
fi

pass=`echo $2 | md5sum |cut -f1 -d" "`
pass=md5$pass

Q1="CREATE ROLE $2 PASSWORD ${BTICK}$pass${BTICK}  LOGIN;"
createdb -e $1 --owner=$2



#echo "$SQL"

pgsql -e "$Q1"

