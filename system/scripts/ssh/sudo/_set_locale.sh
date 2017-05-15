#!/bin/sh
echo LANG=$1 LANGUAGE=\"$2\"  >/tmp/_set_loca
localectl set-locale LANG=$1 LANGUAGE=\"$2\" 