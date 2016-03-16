#!/bin/bash

backup_path=`cat -`

engine=`echo $backup_path -cut -1 -d:`
path=`echo $backup_path -cut -2 -d:`

docker exec -i $engine /home/services/$path/backup.sh