#!/bin/bash


ifconfig  docker0  |grep "inet addr" |cut -f2 -d: |cut -f1 -d" "	
