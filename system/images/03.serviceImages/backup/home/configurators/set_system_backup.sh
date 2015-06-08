#!/bin/bash

service_hash=$1

echo $1 >/home/configurators/saved/system_backup

. /home/engines/scripts/functions.sh

load_service_hash_to_environment
