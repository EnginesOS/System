#!/bin/bash


cd /home/app
 ls -la
echo +++++++++++
whoami

git pull
bundle install --path vendor/bundle
bundle exec rake db:migrate
bundle exec rake db:populate



bundle exec thin -p 8000 start
