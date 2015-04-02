#!/bin/bash

service_hash=$1

. /home/engines/scripts/functions.sh

load_service_hash_to_environment





 if  site_hash[:variables][:fqdn] == nil || site_hash[:variables][:fqdn].length ==0 || site_hash[:variables][:fqdn] == "N/A"  
#         return true 
#       end
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