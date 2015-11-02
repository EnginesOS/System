#!/bin/bash

cd /home/
	export USER $1
	source /home/config_functions.sh
	copy_substituted_templates
					
