#!/bin/sh

mkdir /opt/engines/tmp/$1
chgrp containers /opt/engines/tmp/$1
chmod 777 /opt/engines/tmp/$1

