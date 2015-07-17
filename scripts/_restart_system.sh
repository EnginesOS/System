#!/bin/sh

docker stop `docker ps |awk '{print $1}'` 
shutdown -r now