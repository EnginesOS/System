#!/bin/sh
id data-user | cut -f2 -d: |grep $data_uid >/dev/null	
 if test $? -ne 0
  then
    /usr/sbin/usermod -u $data_uid data-user
 fi

chown -R $data_uid.$data_gid /home/app 
chmod -R 774 /home/fs_src
chmod g+rx ` find /home/fs_src -type d`

chmod -R g+r /home/app
 	for dir in  `find /home/app -type d | sed "/ /s/+_+//g"` 
	  do
		if test `echo $dir |grep _+_ |wc -l ` -lt 1
			then 
				chmod g+x  $dir 
		fi
	  done
  
