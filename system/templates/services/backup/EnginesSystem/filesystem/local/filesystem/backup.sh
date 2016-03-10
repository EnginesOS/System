#!/bin/bash


tar -cpf - $VOLDIR  2>  /tmp/tar.errors.txt

if test $? -ne 0
 then
 cat /tmp/tar.errors.txt
exit -1
 fi
exit 0

