Engines OS Personal & Small Business PAAS

Engines are containerised servers and service providers that are defined by blueprints.
Blueprints are created by the Blueprint Designer and published in galleries.
Engine OS provides 
 End users with the ability to select and install engines from a gallery 
 End users access to opensource source solutions without ever seeing a commandline
 Developers direct access to Endusers 
 End users the freedom to mix and match soltutions with isolated and shared data in a single environment on a single bill.     
 ...
 
 This is the base system
 see https://github.com/EnginesOS/BluePrint-Designer.git for the Blue Print Designer
 see https://github.com/EnginesOS/SystemGui.git for the System Gui

Commands
bin/engos.rb
useage: engos.rb <service|engine> <service_name|engine_name|all> action
actions 
stop
start
pause
unpause
restart
logs
ps
destroy
deleteimage
create
registersite
deregistersite
monitor
demonitor
stats
status
lasterror


Directorys in this Repository

bin
executable scripts

lib
libaries used by scripts and gui

etc
Skeleton

run
Skelton

run/containers
Sekleton

run/services/
Skeleton

run/servcices/*/
Config.yaml specifing the service 

system/images
definitions for images of framworks/stacks (used by engines and services)


system/images
Source for scripts and templates used in building engines 