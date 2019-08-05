#!/bin/sh
BUNDLE_DIR=/tmp/backup_bundles/$1
FS_ROOT=/var/lib/engines/apps/
for fs in `ls $BUNDLE_DIR/filesystem/local/filesystem/*.lnk`
 do
  name=`basename $fs |cut -f1 -d.`
  echo ln -s $FS_ROOT/$1/$name $BUNDLE_DIR/filesystem/local/filesystem/$name >> /tmp/linking
  ln -s $FS_ROOT/$1/$name $BUNDLE_DIR/filesystem/local/filesystem/$name
 done
if test -d /opt/engines/run/apps/$1 
 then
  if test -d $BUNDLE_DIR
    then
    sudo -n /opt/engines/system/scripts/backup/sudo/_archive_engine_bundle.sh  $BUNDLE_DIR $1  
     # tar -cpf - $BUNDLE_DIR /opt/engines/run/apps/$1
      #UNCOMMENT FOR PRODUCTION 
    #   if test $? -eq 0
    #    then
    #     rm -r $BUNDLE_DIR
    #   fi 
  else
   echo '{"result":"error","mesg":"No bundle dir"}'
   exit 2
 fi
 else
   echo '{"result":"error","mesg":"No engine dir"}'
   exit 2
fi
        