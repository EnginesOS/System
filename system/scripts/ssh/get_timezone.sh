#!/bin/bash
     
 readlink /etc/localtime | sed "s/\/usr\/share\/zoneinfo\///" | sed "s/\.\.//"
 
