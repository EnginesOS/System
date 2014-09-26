#!/bin/bash


cd /home/app
 . /etc/rvmrc 
rvm  --default use ruby-2.1.2

git pull


bundle install --path vendor/bundle

bundle exec rake db:migrate
bundle exec rake db:populate

bundle exec thin -p 8000   --ssl --ssl-key-file /opt/engos/etc/ssl/certs/engines.key --ssl-cert-file /opt/engos/etc/ssl/keys/engines.crt start
