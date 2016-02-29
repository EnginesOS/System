#!/bin/sh
#FIXME check for .. and other nasties
mkdir -f /opt/engines/tmp/$1
chgrp  -R  containers /opt/engines/tmp/$1
chmod 777 -R /opt/engines/tmp/$1

