#!/bin/sh

echo rm_ftp_service.sh
TS=` date +%Y%m%d%H%M%S`
echo $TS: $SSH_ORIGINAL_COMMAND >> rm.log
#FIXME should be /var/log/engines/services/auth/ftp/rm.log
