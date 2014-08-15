<h2>Engines OS Personal & Small Business PAAS
</h2>

Engines are containerised servers and service providers that are defined by blueprints.
<br>
Blueprints are created by the Blueprint Designer and published in galleries.
<p>
<strong>Engine OS provides
</strong> 
<br>
 End users with the ability to select and install engines from a gallery 
<br>
 End users access to opensource source solutions without ever seeing a commandline
<br>
 Developers direct access to Endusers 
<br>
 End users the freedom to mix and match solutions with isolated and shared data in a single environment on a single bill.
<br>   
End users complete total control of their data
<br>  
End Users choice of jusristritions where they host, unlike SAS
 ...
<p>
<strong>This repository contains the base system</strong>
<br>
See https://github.com/EnginesOS/BluePrint-Designer.git for the Blue Print Designer
<br>
See https://github.com/EnginesOS/SystemGui.git for the System Gui
<br>
See https://github.com/EnginesOS-Blueprints for available blueprints
<p>
<strong> Commands 
</strong>
<p>

bin/engos.rb
<br>
useage: engos.rb <service|engine> <service_name|engine_name|all> action
<br>
actions 
<br>
stop
<br>
start
<br>
pause
<br>
unpause
<br>
restart
<br>
logs
<br>
ps
<br>
destroy
<br>
deleteimage
<br>
create
<br>
registersite
<br>
deregistersite
<br>
monitor
<br>
demonitor
<br>
stats
<br>
status
<br>
lasterror
<br>

<p>
<strong>Directorys in this Repository
</strong>
<p>
bin<br>
executable scripts
<br>
<p>
lib
<br>
libaries/Classes used by scripts and gui
<p>
etc
<br>
Skeleton
<p>
run
<br>
Skeleton
<p>
run/containers
<br>
Sekeleton
<p>
run/services/
<br>
Skeleton
<p>
run/servcices/*/
<br>
Config.yaml specifing the service 
<p>
system/images
<br>
definitions for images of framworks/stacks (used by engines and services)
<p>

system/images
<br>
Source for scripts and templates used in building engines 
<p>