#!/bin/sh
#args backupname src_url dest_url
#src_url engine:fs:volume or engine:mysql|pgsql|..:user:pass@host/dbname
#publify publify:fs:publifyfs
#dest_url proto:user:pass@host/dir
#file:::/backups/
#ftp:back:backup@somehost.domain.com/dir

 echo "$*" >>/var/log/backup/addbackup.log

Backup_ConfigDir=/home/backup/.duply/
#
# makebackconf.sh  publifydb  publify:mysql:publifydb:publifydb@mysql.engines.internal/publifydb ftp:engback:back_eng@203.14.203.141/publifydb
#bash makebackconf.sh publify publify:fs:publifyfs ftp:engback:back_eng@203.14.203.141/publify


src_engine=`echo $2 |cut -f 1 -d:`
src_type=`echo $2 |cut -f 2 -d:`
src_vol=`echo $2 |cut -f 3 -d:`

mkdir -p $Backup_ConfigDir/$1

        if test $src_type = "fs"
          then
                src=/backup_src/volumes/$src_vol
          else
echo "src type $src_type"
                part=`echo $2 | cut -f 1 -d@`
                flavor=`echo $part | cut -f 2 -d:`
                dbuser=`echo $part | cut -f 3 -d:`
                dbpass=`echo $part | cut -f 4 -d:`

                end=`echo $2 | cut -f 2 -d@`
                dbhost=`echo $end |cut -f 1 -d/`
                dbname=`echo $end |cut -f 2 -d/`

                echo "#!/bin/sh " > $Backup_ConfigDir/$1/pre
                echo "dbflavor=$flavor" >> $Backup_ConfigDir/$1/pre
                echo "dbhost=$dbhost" >> $Backup_ConfigDir/$1/pre
                echo "dbname=$dbname" >> $Backup_ConfigDir/$1/pre
                echo "dbuser=$dbuser" >> $Backup_ConfigDir/$1/pre
                echo "dbpass=$dbpass" >> $Backup_ConfigDir/$1/pre
                cat /home/tmpl/duply_sql_pre >>  $Backup_ConfigDir/$1/pre

                cp /home/tmpl/duply_sql_post  $Backup_ConfigDir/$1/post
                chmod u+x $Backup_ConfigDir/$1/pre
                 chmod u+x $Backup_ConfigDir/$1/post
                src=/home/sql_dumps
        fi

dest_proto=`echo $3 |cut -f1 -d:`
        if test $dest_proto = "file"
                then
                 path=`echo $3 |cut -f4 -d:`
                  dest=/var/lib/engines/local_backup_dests/$path
          else
                first=`echo $3 |cut -f1 -d@`
                user=`echo $first |cut -f2 -d:`
                pass=`echo $first |cut -f3 -d:`
                rest=`echo $3 |cut -f2 -d@`
                host=`echo $rest |cut -f1 -d/`
                path=`echo $rest |cut -f2 -d/`
                dest="$dest_proto://$host/$path"
        fi




cp /home/tmpl/duply_conf $Backup_ConfigDir/$1/conf

echo "SOURCE='$src'" >>$Backup_ConfigDir/$1/conf
echo "TARGET='$dest'" >>$Backup_ConfigDir/$1/conf
echo "TARGET_USER='$user'"  >>$Backup_ConfigDir/$1/conf
echo "TARGET_PASS='$pass'"  >>$Backup_ConfigDir/$1/conf
                 