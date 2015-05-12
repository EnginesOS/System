#!/bin/sh

echo rm_ftp_service.sh
TS=` date +%Y%m%d%H%M%S`
echo $TS: $SSH_ORIGINAL_COMMAND >> /var/log/engines/services/auth/ftp/rm.log

