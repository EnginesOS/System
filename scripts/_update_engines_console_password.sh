#!/bin/sh

echo 'engines:$1'  | chpasswd -e

exit $?