#!/bin/bash
rm /tmp/back_up.errs
backup_path=`cat -`
echo backup path $backup_path
service=`echo $backup_path | cut -f 1 -d:`


	docker exec -i $service /home/engines/services/backup.sh 2> /tmp/back_up.errs

cat /tmp/back_up.errs >&2
  exit 0