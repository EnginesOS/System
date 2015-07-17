#!/bin/sh
sleep 5
docker stop `docker ps |awk '{print $1}'` 
shutdown -r now