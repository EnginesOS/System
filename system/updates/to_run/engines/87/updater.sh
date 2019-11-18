#!/bin/sh

for file in `find /opt/engines/run/services -name running.yaml`
 do
   cat $file |  sed "s/ManagedService/Memento/" > /tmp/running.yaml
   cp /tmp/running.yaml $file 
 done 
 
 for file in `find /opt/engines/run/apps -name running.yaml`
 do
   cat $file |  sed "s/ManagedEngine/Memento/" > /tmp/running.yaml
   cp /tmp/running.yaml $file 
 done 
 
 for file in `find /opt/engines/run/utility -name config.yaml`
 do
   cat $file |  sed "s/ManagedUtility/Memento/" > /tmp/running.yaml
   cp /tmp/running.yaml $file 
 done
 
  for file in `find /opt/engines/run/system_services -name running.yaml`
 do
   cat $file |  sed "s/SystemService/Memento/" > /tmp/running.yaml
   cp /tmp/running.yaml $file 
 done 