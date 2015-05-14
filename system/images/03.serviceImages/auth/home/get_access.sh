#!/bin/sh

service=`echo $0 | cut -f 5 -d/`
cat /home/auth/access/$service/access