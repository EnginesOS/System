#!/bin/bash

if [ -f /etc/timezone ]; then
      cat /etc/timezone
    elif [ -h /etc/localtime ]; then
      readlink /etc/localtime | sed "s/\\/usr\\/share\\/zoneinfo\\///"
    else
      checksum=\`md5sum /etc/localtime | cut -d' ' -f1\`
      find /usr/share/zoneinfo/ -type f -exec md5sum {} \\; | grep "^$checksum" | sed "s/.*\\/usr\\/share\\/zoneinfo\\///" | head -n 1
    fi