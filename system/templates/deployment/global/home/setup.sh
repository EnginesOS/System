#!/bin/bash

cd /home/
		source /home/config_functions.sh
		copy_substituted_templates		
		cd /home/app			
	
	
	if test -f /home/engines/scripts/custom_install.sh 
	then
		echo running custom install
	    bash /home/engines/scripts/custom_install.sh
	fi 
	
	