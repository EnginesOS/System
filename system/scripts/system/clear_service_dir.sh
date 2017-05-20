#!/bin/bash

if test $# -eq 1
  then
	sudo -n  /opt/engines/system/scripts/system/sudo/_clear_service_dir.sh  $1
fi