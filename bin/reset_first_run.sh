#!/bin/bash

engines service mgmt stop
engines service mgmt destroy

if test -d /opt/engines/run/services-disabled/firstrun
 then
	mv /opt/engines/run/services-disabled/firstrun /opt/engines/run/services/firstrun
 elif  test -d /opt/engines/run/services-available/firstrun
 then
 	mv /opt/engines/run/services-available/firstrun /opt/engines/run/services/firstrun
 end

rm /opt/engines/run/system/flags/first_ran 
engines service firstrun create
 