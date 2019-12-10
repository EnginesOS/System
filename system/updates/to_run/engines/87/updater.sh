#!/bin/sh

for file in `find /opt/engines/run/services -name running.yaml`
 do
   cat $file |  sed "s/ManagedService/Memento/"  | sed "s/setState/set_state/"> /tmp/running.yaml
   cp /tmp/running.yaml $file 
 done 
 
 for file in `find /opt/engines/run/apps -name running.yaml`
 do
   cat $file |  sed "s/ManagedEngine/Memento/" | sed "s/setState/set_state/"> /tmp/running.yaml
   cp /tmp/running.yaml $file 
 done 
 
 for file in `find /opt/engines/run/utilitys -name config.yaml`
 do
   cat $file |  sed "s/ManagedUtility/Memento/" | sed "s/setState/set_state/"> /tmp/running.yaml
   cp /tmp/running.yaml $file 
 done
 
  for file in `find /opt/engines/run/system_services -name running.yaml`
 do
   cat $file |  sed "s/SystemService/Memento/" | sed "s/setState/set_state/"> /tmp/running.yaml
   cp /tmp/running.yaml $file 
 done 


   for ftype in services apps utilitys system_services
   do
     for file in `find /opt/engines/run/$ftype  -name running.yaml`
     do     
        cat $file |  sed "s/set_state: /set_state: :/" |sed "s/set_state: ::/set_state: :/" > /tmp/running.yaml
        cp /tmp/running.yaml $file                 
     done
  done