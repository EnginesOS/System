#!/bin/sh
    for task in $*
     do
     mod=`echo $task | sed "/[;&]/s///g"`
     echo "/usr/local/rbenv/shims/bundle exec rake $task"
     /usr/local/rbenv/shims/bundle exec rake $task
     done