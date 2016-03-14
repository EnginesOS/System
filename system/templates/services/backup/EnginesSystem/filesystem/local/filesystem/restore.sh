#!/bin/bash
cd /
cat - |gzip -d | tar -xpf - 
