#!/bin/sh

for backup in `ls /etc/duply/`
        do
                duply $backup backup
        done
