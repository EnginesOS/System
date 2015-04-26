#!/bin/sh
 
function rm_container_state ()
{
	rm -r /client/state/*
}
function rm_container_logs ()
{
	rm -r /client/log/*
}
function rm_container_fs ()
{
	rm -r /dest/fs/*
} 

for cmd in $*
 do
  case cmd in
 	state)
 		rm_container_state
 		;;
 	logs)
 		rm_container_logs
 		;;
 	fs)	
 		rm_container_fs
 		;;
 	all)
 		rm_container_state
 		rm_container_logs
 		rm_container_fs
 		;;
  esac
 done
 
#VOLUME /client/var/log
#VOLUME /client/log
#VOLUME /client/state
#VOLUME /client/fs
#VOLUME /dest/fs


