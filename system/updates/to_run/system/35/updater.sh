#!/bin/sh

if ! test -d /opt/engines/run/public/services
 then
  mkdir -p /opt/engines/run/public/services
  chown engines  /opt/engines/run/public/services
fi

