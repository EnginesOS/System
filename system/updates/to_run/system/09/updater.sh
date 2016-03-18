#!/bin/bash

chown engines /var/lib/engines/fs/*
docker pull engines/volbuilder:`cat /opt/engines/release`