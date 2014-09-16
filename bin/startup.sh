#!/bin/bash

/opt/engos/bin/engines.rb service start dns 
sleep 10
/opt/engos/bin/engines.rb service start nginx 
sleep 10
/opt/engos/bin/engines.rb service check_and_act all
sleep 10
/opt/engos/bin/engines.rb engine check_and_act all