<h2>Engines OS Personal & Small Business PAAS</h2>

Engines are containerised servers and service providers that are defined by blueprints.</br>
Blueprints are created by the Blueprint Designer and published in galleries.</br>
Engine OS provides </br>
 End users with the ability to select and install engines from a gallery 
 End users access to opensource source solutions without ever seeing a commandline</br></br>
 Developers direct access to Endusers </br>
 End users the freedom to mix and match soltutions with isolated and shared data in a single environment on a single bill.</br>     
 ...
 <p>
 <strong>This is the base system</strong></br>
 see https://github.com/EnginesOS/BluePrint-Designer.git for the Blue Print Designer</br>
 see https://github.com/EnginesOS/SystemGui.git for the System Gui</br>
<p>
<strong> Commands </strong>
<p>

bin/engos.rb</br>
useage: engos.rb <service|engine> <service_name|engine_name|all> action</br>
actions </br>
stop</br>
start</br>
pause</br>
unpause</br>
restart</br>
logs</br>
ps</br>
destroy</br>
deleteimage</br>
create</br>
registersite</br>
deregistersite</br>
monitor</br>
demonitor</br>
stats</br>
status</br>
lasterror</br>

<p>
<strong>Directorys in this Repository</strong>
<p>
bin
executable scripts</br>
<p>
lib</br>
libaries used by scripts and gui
<p>
etc</br>
Skeleton
<p>
run</br>
Skelton
<p>
run/containers</br>
Sekleton
<p>
run/services/</br>
Skeleton
<p>
run/servcices/*/</br>
Config.yaml specifing the service 
<p>
system/images</br>
definitions for images of framworks/stacks (used by engines and services)
<p>

system/images</br>
Source for scripts and templates used in building engines 
<p>