#!/bin/sh

/usr/sbin/usermod -u $data_uid data-user
chown -R $data_uid.$data_gid /home/app /home/fs_src
chmod -R 770 /home/fs_src