#!/bin/bash

engines service mgmt stop
engines service mgmt destroy
mv /opt/engines/run/services-disabled/firstrun /opt/engines/run/services/firstrun 

rm /opt/engines/run/system/flags/first_ran 
engines service firstrun create
 