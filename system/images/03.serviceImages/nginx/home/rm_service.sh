#!/bin/bash

service_hash=$1

. /home/engines/scripts/functions.sh

load_service_hash_to_environment




#     begin
#       #        #  ssh_cmd=SysConfig.rmSiteCmd +  " \"" + hash_to_site_str(site_hash) +  "\""
#       #        #FIXME Should write site conf file via template (either standard or supplied with blueprint)
#       #        ssh_cmd = "/opt/engines/scripts/nginx/rmsite.sh " + " \"" + hash_to_site_str(site_hash)   +  "\""
#       #        SystemUtils.debug_output ssh_cmd
#       #        result = run_system(ssh_cmd)
#       site_filename = get_site_file_name(site_hash)
#       if File.exists?(site_filename)
#         File.delete(site_filename)
#       end
#       result = restart_nginx_process()