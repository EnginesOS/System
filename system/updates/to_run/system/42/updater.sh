#!/bin/sh
mkdir -p /var/lib/engines/services/smtp/{dkim,spool}
chown -R 22003 /var/lib/engines/services/smtp/{dkim,spool}