

function create_mgmt_script_key {
	script_name=$1
	ssh-keygen -f ~/.ssh/mgmt/${script_name} -N ""
	pubkey=`cat ~/.ssh/mgmt/${script_name}.pub`
	echo "command=\"/opt/engines/bin/${script_name}.sh\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty  $pubkey " >  ~/.ssh/_${script_name}_authorized_keys
	cat ~/.ssh/_${script_name}_authorized_keys >> ~/.ssh/authorized_keys.system
	cp ~/.ssh/mgmt/${script_name} ~/.ssh/mgmt/${script_name}.pub /opt/engines/etc/ssh/keys/services/mgmt
	echo cp ~/.ssh/mgmt/${script_name} ~/.ssh/mgmt/${script_name}.pub /opt/engines/etc/ssh/keys/services/mgmt
}


function regenerate_keys {
for script_name in `cat /opt/engines/etc/ssh/key_names`
	
do			
				create_mgmt_script_key  $script_name 

		done 
		
if test -f ~/.ssh/authorized_keys.system
 		then 	
 			cat ~/.ssh/authorized_keys.system > ~/.ssh/authorized_keys
 		fi
 chmod og-rw  /home/engines/.ssh/authorized_keys
}

function refresh_mgmt_keys {


	#set_hostname restart_mgmt restart_system deb_update_status update_system access_system update_system_access regen_private update_engines_system_software update_engines_console_password
	for script_name in `cat /opt/engines/etc/ssh/key_names`
		do
			if ! test -f ~/.ssh/mgmt/${script_name}.pub
			 then			
				create_mgmt_script_key  $script_name
			fi
		done 

 	if test -f ~/.ssh/authorized_keys.system
 		then 	
 			cat ~/.ssh/authorized_keys.system > ~/.ssh/authorized_keys
 		fi
 chmod og-rw  /home/engines/.ssh/authorized_keys
}

function generate_keys {
echo "Generating system Keys"
keys=""

	for key in $keys
		do
		  ssh-keygen -q -N "" -f $key
	      cat $key.pub | awk '{ print $1 " " $2}' >$key.p
	      mv  $key.p $key.pub
	      mv $key /opt/engines/etc/keys/
	      cp $key.pub /opt/engines/system/images/03.serviceImages/$key/
	   done
	
}
