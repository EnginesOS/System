#!/bin/bash
BTICK='`'
EXPECTED_ARGS=3
E_BADARGS=65
PQSQL=" su  postgres  -c  /usr/bin/psql `"


if [ $# -ne $EXPECTED_ARGS ]
then
echo "Usage: $0 dbname dbuser dbpass"
exit $E_BADARGS
fi

echo "CREATE USER $2 WITH Encrypted PASSWORD ${BTICK}$3${BTICK};" >/tmp/t.sql
echo "CREATE DATABASE $1;">>/tmp/t.sql
echo "GRANT ALL PRIVILEGES ON DATABASE $1 to $2;" >>/tmp/t.sql

result=`$PQSQL</tmpt.sql`