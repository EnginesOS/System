#!/bin/sh
netstat -ni |egrep -v "veth|docker|lo" | egrep -v 'Iface|Kernel' |awk '{print $1" "$3" "$7}'