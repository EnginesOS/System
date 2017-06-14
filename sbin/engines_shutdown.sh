#!/bin/bash
echo Shutting Down Engines
/usr/bin/docker stop -t 120 `/usr/bin/docker ps |awk '{print $1}' |grep -v CONTAI `