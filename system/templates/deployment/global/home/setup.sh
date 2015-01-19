#!/bin/bash

cd /home/
		source /home/config_functions.sh
		copy_substituted_templates		
		cd /home/app			
	fi
	
	if test -f /home/engines/scripts/post_install.sh
				then 				
				echo "Running Post Install"
				/bin/bash /home/engines/scripts/post_install.sh 
	fi
	
	