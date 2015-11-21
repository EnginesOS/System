#/!bin/sh
eservice status avahi  |grep -i running
 if test $? -eq 0
  then
		eservice stop avahi
		eservice start avahi
 fi