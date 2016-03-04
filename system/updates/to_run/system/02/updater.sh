#!/bin/bash

   chown -R 21000 /opt/engines/system/updates/failed/engines /opt/engines/system/updates/has_run/engines /opt/engines/system/updates/to_run/engines
       echo "engines update $0" >>/tmp/engines_system_update
echo Done the System chown Stuff
exit 0
    