#/bin/bash

chown $fw_user -R /cont/log/
chown $fw_user -R /cont/run/
chown $fw_user -R /cont/state/

chown $fw_user -R /cont/persistant

if test -n $vols
	then
		for vol in $vols
			do