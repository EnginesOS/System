#!/bin/bash

mv /var/lib/engines/fs /var/lib/engines/apps
ln -s /var/lib/engines/apps /var/lib/engines/fs
