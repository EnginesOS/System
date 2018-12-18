#!/bin/bash


ifconfig  docker0  |grep "inet" |head -1 |awk '{print $2}'
