#!/bin/bash
rm /tmp/back_up.errs
backup_path=`cat -`
echo backup path $backup_path
engine=`echo $backup_path | cut -f 1 -d:`



path=`echo $backup_path | cut -f 2 -d:`
if test $path = 'system'
 then
     if test -d /opt/engines/run/apps/$engine
      then
    	tar -cpf - /opt/engines/run/apps/$engine | gzip -c 2> /tmp/back_up.errs
      else
      	echo "No such Engine" >&2
      fi 
else
	docker exec -i $engine /home/services/$path/backup.sh 2> /tmp/back_up.errs
fi

cat /tmp/back_up.errs >&2
  exit 0