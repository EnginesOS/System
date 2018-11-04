#!/bin/bash

release=`cat /opt/engines/release`
 docker pull engines/volbuilder:$release

  
services=` engines services container_name |tr '"[],' ' '`
echo $services
        for service in $services
                 do
                 if test -f /opt/engines/run/services/$service/running.yaml
                  then
                   set_state=`/opt/engines/bin/engines service $service state`
                    if  ! test `/opt/engines/bin/engines service $service state` = nocontainer
                     then
                        /opt/engines/bin/engines service $service stop
                        image=`grep image /opt/engines/run/services/$service/running.yaml | cut -f2 -d" "`
                        docker pull $image

                        /opt/engines/bin/engines service $service wait_for stop 60
                        rm /opt/engines/run/services/$service/running.yaml*
                        /opt/engines/bin/engines service $service recreate

                        if  test $set_state= running
                         then
                        /opt/engines/bin/engines service $service wait_for start 30
                        /opt/engines/bin/engines service $service wait_for_startup 60
                         fi
                   fi
                  fi
                 done

 docker rmi `docker images |grep none |awk '{print $3}'`
