#!/bin/sh
if ! test -f /opt/engines/etc/services/mapping/ManagedEngine/secrets.yaml 
 then
  ln -s /opt/engines/etc/services/providers/EnginesSystem/secrets/secrets.yaml /opt/engines/etc/services/mapping/ManagedEngine/
rm  