#!/bin/bash

service_hash=$1

. /home/engines/scripts/functions.sh

load_service_hash_to_environment

if test -z $fqdn
 then
 	Error:no FQDN in nginx service hash
 	exit -1
 fi
 
 if test -z $port
 then
 	Error:no port in nginx service hash
 	exit -1
 fi
  if test -z $proto
 then
 	Error:no proto in nginx service hash
 	exit -1
 fi
 
   if test -z $name
 then
 	Error:no name in nginx service hash
 	exit -1
 fi
 
 nslookup ${name}.engines.internal
 if test $? -lt 0
  then
  	echo Error:failed to find internal dns entry for site
  	exit -1
 fi  

template="/etc/nginx/templates/${proto}_site.tmpl"

cat $template | sed "/FQDN/s//$fqdn/" > /tmp/site.fqdn
cat /tmp/site.fqdn  | sed "/PORT/s//$port/" > /tmp/site.port
cat /tmp/site.port  | sed "/SERVER/s//$name/" > /tmp/site.name

	if !test $proto http
	 then
	 	if test -f /etc/nginx/ssl/certs/$fqdn.crt
	 		then
	 			cert_name=$fqdn
	        else
	        	 c=engines
	        fi
	    cat /tmp/site.port  | sed "/CERTNAME/s//$CERTNAME/" > /etc/nginx/sites_enabled/${proto}_${fqdn}.site
	 else
	 	cp /tmp/site.name /etc/nginx/sites_enabled/${proto}_${fqdn}.site
	 fi
	 
	 rm /tmp/site.*
	 
	 kill -HUP `cat /var/run/nginx.pid`
	 
	 echo Success
#       
#       proto = site_hash[:variables][:proto]
#       if proto =="http https"
#         template_file=SysConfig.HttpHttpsNginxTemplate
#       elsif proto =="http"
#         template_file=SysConfig.HttpNginxTemplate
#       elsif proto == "https"
#         template_file=SysConfig.HttpsNginxTemplate
#       elsif proto == nil
#         p "Proto nil"
#         template_file=SysConfig.HttpHttpsNginxTemplate
#       else
#         p "Proto" + proto + "  unknown"
#         template_file=SysConfig.HttpHttpsNginxTemplate
#       end
#
#       file_contents=File.read(template_file)
#       site_config_contents =  file_contents.sub("FQDN",site_hash[:variables][:fqdn])
#       site_config_contents = site_config_contents.sub("PORT",site_hash[:variables][:port])
#       site_config_contents = site_config_contents.sub("SERVER",site_hash[:variables][:name]) #Not HostName
#       if proto =="https" || proto =="http https"
#         site_config_contents = site_config_contents.sub("CERTNAME",get_cert_name(site_hash[:variables][:fqdn])) #Not HostName
#         site_config_contents = site_config_contents.sub("CERTNAME",get_cert_name(site_hash[:variables][:fqdn])) #Not HostName
#       end
#       if proto =="http https"
#         #Repeat for second entry
#         site_config_contents =  site_config_contents.sub("FQDN",site_hash[:variables][:fqdn])
#         site_config_contents = site_config_contents.sub("PORT",site_hash[:variables][:port])
#         site_config_contents = site_config_contents.sub("SERVER",site_hash[:variables][:name]) #Not HostName
#       end
#
#       site_filename = get_site_file_name(site_hash)
#
#       site_file  =  File.open(site_filename,'w')
#       site_file.write(site_config_contents)
#       
#       site_file.close
#       result = restart_nginx_process()
#       return result
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end