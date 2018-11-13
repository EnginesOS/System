#!/bin/bash
. /home/engines/functions/params_to_env.sh
params_to_env

tar -cpf - $engine_path |gzip -c 


