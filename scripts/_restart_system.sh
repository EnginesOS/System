#!/bin/sh
sleep 30
docker stop `docker ps |awk '{print $1}'` 
shutdown -r now