#!/bin/sh

for backup in `ls /etc/duply/`
        do
        		ts=`date +%d_%m_%y`
        		bfn=$backup_$ts.log        		
                duply $backup backup >/var/log/$bfn
        done
