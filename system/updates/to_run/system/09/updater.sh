#!/bin/bash

chown engines /var/lib/engines/apps/*
docker pull engines/volbuilder:`cat /opt/engines/release`