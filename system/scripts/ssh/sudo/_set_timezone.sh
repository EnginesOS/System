#!/bin/sh
echo timedatectl set-timezone $1 >/tmp/_set_tz
timedatectl set-timezone $1


