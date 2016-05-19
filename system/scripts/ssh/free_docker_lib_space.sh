#!/bin/sh

space=`df -k /var/lib/docker | grep -v Ava | awk '{print $4}'`

echo -n $space