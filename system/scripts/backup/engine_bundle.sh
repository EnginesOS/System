#!/bin/sh
BUNDLE_DIR=/tmp/backup/bundles/$1
if test -d /opt/engines/run/apps/$1 
  if test -d $BUNDLE_DIR
    then
     # cp -rp /opt/engines/run/apps/$1 $BUNDLE_DIR
      tar -cpf - $BUNDLE_DIR /opt/engines/run/apps/$1 
       if test $? -eq 0
        then
         rm -r $BUNDLE_DIR
       fi 
  else
   echo '{"result":"error","mesg":"No bundle dir"}'
   exit 2
 fi
 else
   echo '{"result":"error","mesg":"No engine dir"}'
   exit 2
fi
        