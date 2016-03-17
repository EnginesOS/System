#!/bin/bash

tar -cpf - /var/log/engines/  | gzip -c