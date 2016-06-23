#!/bin/bash
echo mv /var/lib/docker/containers/$1/$1-json.log /var/log/engines/raw/$1-json.last  &>>/tmp/clean.log
mv /var/lib/docker/containers/$1/$1-json.log /var/log/engines/raw/$1-json.last  &>>/tmp/clean.log

#exit