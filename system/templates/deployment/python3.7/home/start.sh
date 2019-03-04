#!/bin/sh

virtualenv --system-site-packages /home/app/venv
 if test -f /home/app/venv/bin/activate
  then
   echo Activating virtual env
   . /home/app/venv/bin/activate
 fi
 echo Start Calling /home/_start.sh
 /home/_start.sh
 
