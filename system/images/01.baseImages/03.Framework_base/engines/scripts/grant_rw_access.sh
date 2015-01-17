#!/bin/sh
path=`echo $1 |sed "/[ ;\\\.\'\"\`]/s///g"`
sudo -u data-owner /home/engines/scripts/_grant_rw_access.sh $path