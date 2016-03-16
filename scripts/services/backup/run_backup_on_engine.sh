#!/bin/bash

backup_path=`cat -`
echo backup path $backup_path
engine=`echo $backup_path -cut -1 -d:`
path=`echo $backup_path -cut -2 -d:`
echo backup cmd docker exec -i $engine /home/services/$path/backup.sh
docker exec -i $engine /home/services/$path/backup.sh