#!/bin/sh

if ! test -d /opt/engines/run/services/settings/
 then
   mkdir /opt/engines/run/services/settings/
 fi
chown -R engines.containers /opt/engines/run/services/settings/

