#!/bin/bash

service_hash=$1

#. /home/engines/scripts/functions.sh

#load_service_hash_to_environment

ssh auth@auth.engines.internal /home/auth/scripts/ftp_add_service.sh $service_hash


