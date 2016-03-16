#!/bin/bash

chown engines /var/lib/engines/fs/*
sudo docker pull engines/volbuilder:`cat /opt/engines/release`