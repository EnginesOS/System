#/bin/bash

$hostname=$1

if ! test -z "$2"
 then
  hostname=${hostname}.$2
  fi
  
  sudo hostname $hostname
