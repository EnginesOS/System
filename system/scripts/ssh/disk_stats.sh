#!/bin/sh
df -k -x aufs -x tmpfs -x devtmpfs -T  |grep -v Filesystem

