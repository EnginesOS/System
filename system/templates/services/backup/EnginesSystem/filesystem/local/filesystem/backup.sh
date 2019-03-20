#!/bin/sh

tar -cpf - $engine_path 2> /dev/null |gzip -c 


