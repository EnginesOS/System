#!/bin/bash


service_hash=$1

#. /home/engines/scripts/functions.sh

#load_service_hash_to_environment

ssh -p 2222 -o StrictHostKeyChecking=no -i ~/.ssh/rm_rsa auth@auth.engines.internal /home/auth/scripts/ftp_rm_service.sh $service_hash