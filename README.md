<h2>Engines - Containerised server for the end user.
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
<h4>Installation</h4>
See https://github.com/EnginesOS/EnginesInstaller

<strong>This repository contains the base system</strong>
<br>
See https://github.com/EnginesOS/BluePrint-Designer.git for the Blue Print Designer
<br>
See https://github.com/EnginesOS/SystemGui.git for the System Gui
<br>
See https://github.com/EnginesBlueprints for available blueprints
<br>
See https://github.com/EnginesOS/EnginesInstallerfor installer
<p>

<strong>Abstract</strong>
Engines is a managed system of containerised applications and services utilizing Docker, the system is managed through a fully featured Rails based web front end. Application images are built locally from public and or private blueprints, this is done to ensure security and compatibility with the local environment and local system services. The aim of Engines is to provide non technical end users the ability to launch a machine (VM or BM) and install a collection of business and/or personal servers on it with the same ease that a tablet user adds applications, but with a finer grain of control on data access and sharing.  
<p>
The use of blueprints and the associated image build process provide the capacity to describe the installation and configuration of a wide range of software, while maintaining both system and data security. This coupled with the ease at which an end user can install software from galleries, we envisage that the engines system will suit:
<li>
Personal users who wish to maintain an online presence with complete data sovereignty deploying packages like Mahara (eportfolio), MediaGoblin, Ownstagram, publify ....
</li>
<li>
Small Businesses  that wish to use a collection of packages, so they can have ERP Software, blogging software, and additional packages on a single bill (or physical host) with complete data sovereignty. There are several packages such as Owncloud and Odoo that provide a rich feature set for work groups. 
</li>
<p>
Currently the only options available to end users to make use of such packages are limited to SAS offerings or hiring a Linux consultant to perform installations of an unknown quality and security. 
<p>


<strong>Licensing and current status</strong>
The system is  currently in Alpha on a weekly release cycle with a planned Beta Release due in August. The software is released under the Apache 2.0 license and is available from https://github.com/EnginesOS/System. Some of the advanced features may be non functional as they are a work in progress. We have an AWS AMI we can share. There is also a youtube video at
Currently there are about 25 applications available in our gallery. Some require further input from the user to complete the installation via a browser, though where possible the installation is automated. These applications represent a range of applications and installation test cases, the small number is not indicative in any way of the number of applications that could be blueprinted with relative ease to run on the engines system. 

  <p>


<strong>Overview</strong>
The Engines system handles the management and orchestration  of services in support of engines that users may install from galleries or custom definitions. The engine and service containers are ephemeral with persistent data stores configured and linked in by the system to maintain data and configuration persistence. Applications are defined in blueprints we refer to these applications as engines. We use a blueprint and build system so as to maintain control over security and enforce a policy that no engine at any time runs as root (including build time). Currently the engines system runs under Ubuntu, in the future will will include support for other Linux flavours, through the provision of additional templates and a base image
<p>
<strong>Services</strong>
The services provide support to applications, each service runs in it's own container, the default installation includes, DNS, database servers, persistent file system, scheduling, web router (nginx) outbound SMTP, volume sharing, backup, logging and more. The system provides support for drop in third party service containers through the use of runtime and service definition configuration files.  Services provided to containers can be persistent like a database which is created before the container image is built or ephemeral like a DNS record which only exists while the container is running. The service definition templates describe the parameters required to attach the service to an object type and to what object types the service can be attached. The service images are kept on docker hub.
Each service is defined by two yamls files, one specifying the runtime parameters for the service container, with the other yaml detailing for what objects the service is applicable for and what are the required parameters to attach this service. For example an FTP or NFS service can only be applied to volume objects, while a backup can be applied to engines, databases and volumes.
The design is such that third party services can be added through a docker image and the two fore mentioned config files
<p>
<strong>User installed engines</strong>
Installed engines can be web applications or server applications such as a git daemon or a minecraft server. Engines are defined by blueprints published in a public/private software gallery. Each engine runs in a separate container, required services are registered and provisioned when needed by the system service manager, as defined in the engine's blueprint. Post installation, users can attach additional services to an engine and it's component services. For example sharing a folder within a persistent file service between engines or attaching sharing services like NFS/FTP/SMBFS/ and drop box backing to a folder within a persistent file service.  When creating a blueprint the blueprint designer is required to test the configurations persistence, so all engines are ephemeral.
<p>
<strong>Management Applications </strong>
Rails based web application that provides engine and service control and monitoring.
Command line utilities than mirror most of the functionality of the GUI, as well as providing  an additional command set suited for use in scripts.
The management suite and backend are independent of all other engines and their services. The end result is a robust managed system  that can bootstrap all other services and engines. 
<p>
<strong>Engine builder</strong>
The engines builder is launched from the web management application. When a user chooses to install an application the builder reads the blueprint and presents the user with a form of mandatory and optional variables for them to enter.  These variables are used to set system parameters such as the external hostname for the web router, as well as for use as variables in templates that are used to write relevant configuration files for the target software and required services. In addition to user entered variables, system variables and services definition variables are available within the templates. Most packages can be installed using defaults supplied by the system and blueprint.  There is a  command line utility that can build an engine, but currently limited to engines with no mandatory user input values defined in the blueprint.
Blue print design studio
The blue print design studio is a Rails web application available as a standalone application or engine. It is to be used by developers and software porters to define and export blueprints for software to be used in the Engines system. The blueprints produced can be for local/in house use or to publish to a gallery server either for public use or private use within a group.
Gallery server
This server provides a listing service for blueprints, it doesn't serve the actual blueprints but does serve the software's details including the licence under which the software is published, along with the URI of the git repository holding the blueprint. Future versions of the gallery will support, comments, voting and licensed commercial software. The Gallery Server is and will remain open source under the Apache 2 licence.
<p>
<strong>Security</strong>
Security is not merely achieved by containerisation, containers run as non privileged users with restrictive file permissions. Containers for applications are built from blueprints in a way there is no scope for any external code to run as root during the container build process or at runtime. 
 To provide flexibility to developers and expert users will be able to load external Docker  images and configure mappings to system resources and create containers, on the understanding that they trust the image they are using. Using this docker image import function applications will be able to run as root if a user chooses.
<p>

<strong>Blueprints </strong>
Applications are defined in blueprints (in JSON) which are created in the Engines Blueprint Design Studio. The blueprints can be hosted locally on the installation or published in a public/private git repository and listed in open/private galleries.
Blueprints define every thing needed to install, configure and secure an application. The blueprinting process is a codification of the installation steps outlined in a software packages installation guide.
<p>
