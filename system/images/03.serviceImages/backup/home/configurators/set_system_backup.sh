#!/bin/bash

service_hash=$1

echo $1 >/home/configurators/saved/system_backup

. /home/engines/scripts/functions.sh

load_service_hash_to_environment


 echo "$*" >>/var/log/backup/addbackup.log

Backup_ConfigDir=/home/backup/.duply/
export

service_hash=`cat /home/configurators/saved/default_destination`
load_service_hash_to_environment
dest=$dest_proto://$dest_address/$dest_folder
user=$dest_user
pass=$dest_pass


				if test  $include_system = "true"
					then
						mkdir -p $Backup_ConfigDir/system
#						cat /home/tmpl/duply_sql_pre >  $Backup_ConfigDir/system/pre
#                		cp /home/tmpl/duply_sql_post  $Backup_ConfigDir/system/post
#                		chmod u+x $Backup_ConfigDir/system/pre
#                		chmod u+x $Backup_ConfigDir/system/post
                		cp /home/tmpl/duply_conf $Backup_ConfigDir/system/conf
                		src=/backup_src/engines
                		echo "SOURCE='$src'" >>$Backup_ConfigDir/system/conf

echo "TARGET='$dest'" >>$Backup_ConfigDir/system/conf
echo "TARGET_USER='$user'"  >>$Backup_ConfigDir/system/conf
echo "TARGET_PASS='$pass'"  >>$Backup_ConfigDir/system/conf
					fi
				if test  $include_databases = "true"
					then
						src=/home/backup/sql_dumps
						mkdir -p $Backup_ConfigDir/system_databases
						cat /home/tmpl/dumpall.sh >  $Backup_ConfigDir/system_databases/pre
                		cp /home/tmpl/dumpall_post.sh  $Backup_ConfigDir/system_databases/post
                		chmod u+x $Backup_ConfigDir/system/pre
                		chmod u+x $Backup_ConfigDir/system/post
                		cp /home/tmpl/duply_conf $Backup_ConfigDir/system_databases/conf
                		echo "SOURCE='$src'" >>$Backup_ConfigDir/system_databases/conf

echo "TARGET='$dest'" >>$Backup_ConfigDir/system_databases/conf
echo "TARGET_USER='$user'"  >>$Backup_ConfigDir/system_databases/conf
echo "TARGET_PASS='$pass'"  >>$Backup_ConfigDir/system_databases/conf
				fi
				
				if test $include_logs = "true"
					then
						mkdir -p $Backup_ConfigDir/system_logs
						src=/backup_src/logs
						cp /home/tmpl/duply_conf $Backup_ConfigDir/system_logs/conf
						echo "SOURCE='$src'" >>$Backup_ConfigDir/system_logs/conf

echo "TARGET='$dest'" >>$Backup_ConfigDir/system_logs/conf
echo "TARGET_USER='$user'"  >>$Backup_ConfigDir/system_logs/conf
echo "TARGET_PASS='$pass'"  >>$Backup_ConfigDir/system_logs/conf
				fi
				
				if test $include_files = "true"
					then
						mkdir -p $Backup_ConfigDir/system_files
						src=/backup_src/volumes/
						cp /home/tmpl/duply_conf $Backup_ConfigDir/system_files/conf
						echo "SOURCE='$src'" >>$Backup_ConfigDir/system_files/conf
				
echo "TARGET='$dest'" >>$Backup_ConfigDir/system_files/conf
echo "TARGET_USER='$user'"  >>$Backup_ConfigDir/system_files/conf
echo "TARGET_PASS='$pass'"  >>$Backup_ConfigDir/system_files/conf
				fi
				

       

  
