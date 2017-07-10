#!/bin/bash


cd /var/lib/engines/cert_auth/

if  test -f public/certs/system_system_engines.crt
then
 mkdir -p public/keys/systems/system
 mkdir -p public/certs/systems/system
 mv public/certs/system_system_engines.crt  public/certs/systems/system/engines.crt 
 mv public/keys/system_system_engines.key public/keys/systems/system/engines.key
 
 fi
 
 if test -f public/certs/service_ivpn_ipvpn.crt
  then
  	mkdir -p public/keys/services/ivpn
  	mkdir -p public/certs/services/ivpn
  	mv public/certs/service_ivpn_ipvpn.crt public/certs/services/ivpn/ipvpn.crt
  	mv public/keys/service_ivpn_ipvpn.key public/keys/services/ivpn/ipvpn.key
  
  fi