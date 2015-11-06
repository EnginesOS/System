#!/bin/sh
    for task in $*
     do
     mod=`echo $task | sed "/[;&]/s///g"`
     /usr/local/rbenv/shims/bundle exec rake $task
     done