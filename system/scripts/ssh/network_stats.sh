#!/bin/bash
netstat -ni |egrep -v "veth|docker|lo" | egrep -v 'Iface|Kernel' |awk '{print $1" "$4" "$8}'