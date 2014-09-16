#!/bin/bash
#FIXME
rvm use ruby-2.1.1

/opt/engos/bin/engines.rb service start dns 
sleep 20
/opt/engos/bin/engines.rb service start nginx 
sleep 20
/opt/engos/bin/engines.rb service check_and_act all
sleep 20
/opt/engos/bin/engines.rb engine check_and_act all