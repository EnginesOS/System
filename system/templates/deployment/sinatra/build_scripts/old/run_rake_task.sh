#!/bin/sh
    for task in $*
     do
     mod=`echo $task | sed "/[;&]/s///g"`
     bundle exec $task
     done