#!/bin/bash
. /home/engines/functions/params_to_env.sh
params_to_env
 if test -z $dbname
  then
   echo dbname cant be nill
   exit -1
  fi 