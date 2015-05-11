#!/bin/sh
 cat ~/.ssh/id_rsa.pub | awk '{print $1 " " $2}'