#!/bin/bash

rm -r /opt/engines/etc/services/providers/* 

cd /opt/engines/etc/services/providers/
  git clone https://github.com/EnginesServices/SumoLogic
	  cd SumoLogic
	  git checkout `cat /opt/engines/release`
	  cd ..
	  git clone https://github.com/EnginesServices/EnginesSystem
	  cd EnginesSystem
	   git checkout `cat /opt/engines/release`
