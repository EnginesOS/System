#!/bin/sh

echo 'sudo -n /opt/engines/system/scripts/system/sudo/_clear_container_dir.sh  $1' >/tmp/clear_cont
if test $# -eq 1
  then
	sudo -n /opt/engines/system/scripts/system/sudo/_clear_container_dir.sh  $1
fi