#!/bin/sh
BUNDLE_DIR=/tmp/backup_bundles/$1
if test -d /opt/engines/run/apps/$1 
 then
  if test -d $BUNDLE_DIR
    then
      tar -cpf - $BUNDLE_DIR /opt/engines/run/apps/$1
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
        