#!/bin/bash

mv /opt/engos /opt/engines
mv /var/log/engos /var/log/engines
mv /var/lib/engos /var/lib/engines
cat ~dockuser/.profile |sed  "s/engos/engines/" |grep engines >/tmp/t
cp /tmp/t ~dockuser/.profile
chown dockuser  ~dockuser/.profile


