#!/bin/bash

cd /home/
		source /home/config_functions.sh
		copy_substituted_templates		
					
	
	
	if test -f engines/scripts/custom_install.sh 
	then
		echo running custom install
	     engines/scripts/custom_install.sh
	fi 
	
	