#!/bin/bash

/opt/engos/bin/engines.rb service dns start
sleep 10
/opt/engos/bin/engines.rb service nginx start
sleep 10
/opt/engos/bin/engines.rb service check_and_act all
sleep 10
/opt/engos/bin/engines.rb engine check_and_act all