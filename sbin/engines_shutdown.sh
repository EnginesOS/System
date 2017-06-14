#!/bin/bash
echo Shutting Down Engines
/usr/bin/docker stop -t 60 `/usr/bin/docker ps |awk '{print $1}' |grep -v CONTAI `