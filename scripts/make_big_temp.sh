#!/bin/sh
#FIXME check for .. and other nasties
mkdir -p /opt/engines/tmp/$1
chgrp  -R  containers /opt/engines/tmp/$1
chmod oug+rwx -R /opt/engines/tmp/$1

