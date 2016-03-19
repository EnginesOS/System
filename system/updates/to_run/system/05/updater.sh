#!/bin/bash

to_map=" dns nginx"
cd /opt/engines/etc/services

for service in $to_map
	do
		service_def=`find providers/ -name ${service}.yaml`
		echo service_def  $service_def 
		cp $service_def mapping/ManagedEngine
    done
    
    exit 0
    
    apt-get install -y  linux-image-virtual apt-transport-https    linux-image-extra-$(uname -r) lvm2 thin-provisioning-tools