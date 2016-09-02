#!/bin/bash

if test $# -gt 0
  then
	sudo -n  /opt/engines/system/scripts/system/sudo/_clear_container_dir.sh  $1
fi