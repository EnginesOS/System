#!/bin/bash
 cat /etc/rc.local | sed "/^su -l engines.*$/s//su -l engines \/opt\/engines\/bin\/engines_startup.sh \>  \/var\/log\/engines\/last_start\.log/" > /tmp/rc.local
 mv /tmp/rc.local /etc
