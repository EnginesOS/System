#!/bin/bash

engines service mgmt stop
engines service mgmt destroy
 rm /opt/engines/run/services/mgmt/running.yaml*

if test -d /opt/engines/run/services-disabled/firstrun
 then
	mv /opt/engines/run/services-disabled/firstrun /opt/engines/run/services/firstrun
 elif  test -d /opt/engines/run/services-available/firstrun
 then
 	mv /opt/engines/run/services-available/firstrun /opt/engines/run/services/firstrun
 fi

rm /opt/engines/run/system/flags/first_ran 
engines service firstrun create
 