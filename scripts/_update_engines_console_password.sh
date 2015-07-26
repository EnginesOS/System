#!/bin/sh

echo $1
echo "engines:\'$1\'  | chpasswd -e"
echo engines:\'$1\'  | chpasswd -e

exit $?