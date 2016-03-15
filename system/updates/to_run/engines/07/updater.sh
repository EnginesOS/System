#!/bin/bash
release=`cat /opt/engines/release`
docker pull engines/volbuilder:$release