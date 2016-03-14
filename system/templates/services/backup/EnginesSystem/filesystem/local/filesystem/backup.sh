#!/bin/bash


tar -cpf - $VOLDIR |gzip -c 2>  /tmp/tar.errors.txt

if test $? -ne 0
 then
 cat /tmp/tar.errors.txt
exit -1
 fi
exit 0

