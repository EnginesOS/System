#!/bin/bash

/opt/engsos/bin/engines.rb service dns start
sleep 10
/opt/engsos/bin/engines.rb service nginx start
sleep 10
/opt/engsos/bin/engines.rb service check_and_act all
sleep 10
/opt/engsos/bin/engines.rb engine check_and_act all