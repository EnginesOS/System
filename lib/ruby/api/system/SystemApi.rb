class SystemApi
   attr_reader :last_error
   def initialize(api)
     @engines_api = api
   end

   def create_container(container)
     clear_error
     begin
       cid = read_container_id(container)
       container.container_id=(cid)       
       return save_container(container)  

     rescue Exception=>e
       container.last_error=("Failed To Create " + e.to_s)
       SystemUtils.log_exception(e)

       return false
     end
   end
#
#   def register_dns_and_site(container)
#     if container.conf_register_dns == true
#       if container.register_dns() == true
#         if container.conf_register_site() == true
#           if container.register_site == true
#             return true
#           else
#             return false  #failed to register
#           end
#         end # if reg site
#       else
#         return false #reg dns failed
#       end
#     end #if reg dns
#     return true
#   end

   def reload_dns
     dns_pid = File.read(SysConfig.NamedPIDFile)
#     p :kill_HUP_TO_DNS
#     p dns_pid.to_s
     return @engines_api.signal_service_process(dns_pid.to_s,'HUP','dns')
   rescue  Exception=>e
     SystemUtils.log_exception(e)
     return false
   end
#
#   def restart_nginx_process
#     begin
#       clear_error
#       cmd= "docker exec nginx ps ax |grep \"nginx: master\" |grep -v grep |awk '{ print $1}'"
#
#       SystemUtils.debug_output("Restart Nginx",cmd)
#       nginxpid= %x<#{cmd}>
#       SystemUtils.debug_output("Nginx pid",nginxpid)
#       #FIXME read from pid file this is just silly
#       docker_cmd = "docker exec nginx kill -HUP " + nginxpid.to_s
#       SystemUtils.debug_output("Nginx restart ",docker_cmd)
#       if nginxpid.to_s != "-"
#         return run_system(docker_cmd)
#       else
#         return false
#       end
#     rescue Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end

   def clear_cid(container)
     container.container_id=(-1)
   end

   def is_startup_complete container
     clear_error
     begin
       runDir=container_state_dir(container)
       if File.exists?(runDir + "/startup_complete")
         return true
       else
         return false
       end
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

 
 

   def clear_cid_file container
     clear_error
     begin
       cidfile =  container_cid_file(container)
       if File.exists? cidfile
         File.delete cidfile
       end
       return true
     rescue Exception=>e
       container.last_error=("Failed To Create " + e.to_s)
       SystemUtils.log_exception(e)

       return false
     end
   end

   def read_container_id(container)
     clear_error
     begin
       cidfile =  container_cid_file(container)
       if File.exists?(cidfile)
         cid = File.read(cidfile)
         return cid
       end
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return "-1";
     end
   end

   def destroy_container container
     clear_error
     begin
       container.container_id=(-1)
       if File.exists?( container_cid_file(container)) ==true
         File.delete( container_cid_file(container))
       end
       return true #File may or may not exist
     rescue Exception=>e
       container.last_error=( "Failed To Destroy " + e.to_s)
       SystemUtils.log_exception(e)

       return false
     end
   end
#
#   def register_dns(top_level_hostname,ip_addr_str)  # no Gem made this simple (need to set tiny TTL) and and all used nsupdate anyhow
#     clear_error
#     begin
#       fqdn_str = top_level_hostname + "." + SysConfig.internalDomain
#       #FIXME need unique name for temp file
#       dns_cmd_file_name="/tmp/.dns_cmd_file"
#       dns_cmd_file = File.new(dns_cmd_file_name,"w+")
#       dns_cmd_file.puts("server " + SysConfig.defaultDNS)
#       dns_cmd_file.puts("update delete " + fqdn_str)
#       dns_cmd_file.puts("send")
#       dns_cmd_file.puts("update add " + fqdn_str + " 30 A " + ip_addr_str)
#       dns_cmd_file.puts("send")
#       dns_cmd_file.close
#       cmd_str = "nsupdate -k " + SysConfig.ddnsKey + " " + dns_cmd_file_name
#       retval = run_system(cmd_str)
#       #File.delete(dns_cmd_file_name)
#       return retval
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end

   def delete_container_configs(container)
     clear_error
  
#       stateDir = container_state_dir(container) + "/config.yaml"
#       File.delete(stateDir)
       cidfile  = SysConfig.CidDir + "/" + container.container_name + ".cid"
       if File.exists?(cidfile)
         File.delete(cidfile)
       end
      cmd = "docker run  --name volbuilder --memory=20m -e fw_user=www-data  -v /opt/engines/run/containers/" + container.container_name + "/:/client/state:rw  -v /var/log/engines/containers/" + container.container_name + ":/client/log:rw    -t engines/volbuilder:" + SystemUtils.system_release + " /home/remove_container.sh state logs"  
      retval =  SystemUtils.run_system(cmd)
       cmd = "docker rm volbuilder"
     retval =  SystemUtils.run_system(cmd)
      
      if retval == true
        Dir.delete(container_state_dir(container))
          return true
      else
        container.last_error=("Failed to Delete state and logs:" + retval.to_s) 
        
        SystemUtils.log_error_mesg("Failed to Delete state and logs:" + retval.to_s ,container)
        return false  
      end
      
     rescue Exception=>e
       container.last_error=( "Failed To Delete " )
       SystemUtils.log_exception(e)
       return false
   end

#   def deregister_dns(top_level_hostname)
#     clear_error
#     begin
#       fqdn_str = top_level_hostname + "." + SysConfig.internalDomain
#       dns_cmd_file_name="/tmp/.top_level_hostname.dns_cmd_file"
#       dns_cmd_file = File.new(dns_cmd_file_name,"w")
#       dns_cmd_file.puts("server " + SysConfig.defaultDNS)
#       dns_cmd_file.puts("update delete " + fqdn_str)
#       dns_cmd_file.puts("send")
#       dns_cmd_file.close
#       cmd_str = "nsupdate -k " + SysConfig.ddnsKey + " " + dns_cmd_file_name
#       retval =  run_system(cmd_str)
#       File.delete(dns_cmd_file_name)
#       return retval
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end

   def get_cert_name(fqdn)
     if File.exists?(SysConfig.NginxCertDir + "/" + fqdn + ".crt")
       return  fqdn
     else
       return SysConfig.NginxDefaultCert
     end
   end

#   def register_site(site_hash)
#     clear_error
#     begin
#       SystemUtils.debug_output("register_site",site_hash)
#       
#       if  site_hash[:variables][:fqdn] == nil || site_hash[:variables][:fqdn].length ==0 || site_hash[:variables][:fqdn] == "N/A"  
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

#   def hash_to_site_str(site_hash)
#     clear_error
#     begin
#       return site_hash[:name].to_s + ":" +  site_hash[:variables][:fqdn].to_s + ":" + site_hash[:variables][:port].to_s  + ":" + site_hash[:variables][:proto].to_s
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end

#   def get_site_file_name(site_hash)
#     file_name = String.new
#     proto = site_hash[:variables][:proto]
#     p :proto
#     p proto
#     if proto == "http https"
#       proto ="http_https"
#     end
#     file_name=SysConfig.NginxSiteDir + "/" + proto + "_" +  site_hash[:variables][:fqdn] + ".site"
#     return file_name
#     
#   end
#
#   def deregister_site(site_hash)
#     clear_error
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
#       return result
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end
#
#
#   def add_monitor(site_hash)
#     clear_error
#     begin
#       ssh_cmd=SysConfig.addSiteMonitorCmd + " \"" + hash_to_site_str(site_hash) + " \""
#       return run_system(ssh_cmd)
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end
#
#   def rm_monitor(site_hash)
#     clear_error
#     begin
#       ssh_cmd=SysConfig.rmSiteMonitorCmd + " \"" + hash_to_site_str(site_hash) + " \""
#       return run_system(ssh_cmd)
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end
#   
  def get_build_report(engine_name)
    clear_error
   
         stateDir=SysConfig.CidDir + "/containers/" + engine_name
    if File.exists?(stateDir  + "/buildreport.txt")
         return File.read(stateDir  + "/buildreport.txt")
    else
      return "Build Not Successful"
    end
                           
      rescue Exception=>e
        SystemUtils.log_exception(e)
        return false
  end
  
   def save_build_report(container,build_report)
      clear_error
      stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.container_name
      f = File.new(stateDir  + "/buildreport.txt",File::CREAT|File::TRUNC|File::RDWR, 0644)
      f.puts(build_report)
      f.close           
       return true
   rescue Exception=>e
     SystemUtils.log_exception(e)
     return false
   end
   
   def save_container(container)
     clear_error
     begin
       #FIXME 
       api = container.core_api
       container.core_api = nil
       serialized_object = YAML::dump(container)
       container.core_api = api
       stateDir = container_state_dir(container)
       #=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.container_name
       if File.directory?(stateDir) ==false
         Dir.mkdir(stateDir)
         Dir.exists?(stateDir + "/run") == false
         Dir.mkdir(stateDir + "/run")
         Dir.mkdir(stateDir + "/run/flags")
         FileUtils.chown_R(nil,"containers",stateDir + "/run")
         FileUtils.chmod_R("u+r",stateDir + "/run")
       end
       log_dir = container_log_dir(container)
       if File.directory?(log_dir) ==false
         Dir.mkdir(log_dir)
       end

       statefile=stateDir + "/config.yaml"
       # BACKUP Current file with rename
       if File.exists?(statefile)
         statefile_bak = statefile + ".bak"
         File.rename( statefile,   statefile_bak)
       end
       f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
       f.puts(serialized_object)
       f.close
       return true
     rescue Exception=>e
       container.last_error=( "save error")
       #FIXME Need to rename back if failure
       SystemUtils.log_exception(e)
       return false
     end
   end

   def save_blueprint(blueprint,container)
     clear_error
     begin
       if blueprint != nil
         puts blueprint.to_s
       else
         return false
       end
       stateDir=container_state_dir(container)
       if File.directory?(stateDir) ==false
         Dir.mkdir(stateDir)
       end
       statefile=stateDir + "/blueprint.json"
       f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
       f.write(blueprint.to_json)
       f.close
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def load_blueprint(container)
     clear_error
     begin
       stateDir=container_state_dir(container)
       if File.directory?(stateDir) ==false
         return false
       end
       statefile=stateDir + "/blueprint.json"
       if File.exists?(statefile)
         f = File.new(statefile,"r")
         blueprint = JSON.parse( f.read())
         f.close
       else
         return false
       end
       return blueprint
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end




   def  save_domains(domains)
     clear_error
     begin
       domain_file = File.open(SysConfig.DomainsFile,"w")
       domain_file.write(domains.to_yaml())
       domain_file.close
       return true
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def load_domains
     clear_error
     begin
       if File.exists?(SysConfig.DomainsFile) == false
#         p :creating_new_domain_list
         domains_file = File.open(SysConfig.DomainsFile,"w")
         domains_file.close
         return Hash.new
       else
         domains_file = File.open(SysConfig.DomainsFile,"r")
       end
       domains = YAML::load( domains_file )
       domains_file.close
       if domains == false
         p :domains_error_in_load
         return Hash.new
       end
       return domains
     rescue Exception=>e
       domains = Hash.new
       p "failed_to_load_domains"
       SystemUtils.log_exception(e)
       return domains
     end
   end

   def list_domains
     domains = load_domains
     return domains
   rescue Exception=>e
     domains = Hash.new
     p :error_listing_domains
     SystemUtils.log_exception(e)
     return domains
   end


   
   def add_domain(params)
     clear_error
     domain= params[:domain_name]
     if params[:self_hosted]
       add_self_hosted_domain params
     end
#     p :add_domain
#     p params
     domains = load_domains()
     domains[params[:domain_name]] = params
     if save_domains(domains)
       return true
     end

     p :failed_add_hosted_domains
     return false

   rescue Exception=>e
     SystemUtils.log_exception(e)
     return false
   end

   def rm_domain(domain,system_api)
     clear_error
     domains = load_domains
     if domains.has_key?(domain)
       domains.delete(domain)
       save_domains(domains)
       system_api.reload_dns
     end

   end

   def  update_domain(old_domain_name, params,system_api)
     clear_error
     begin
       domains = load_domains()
       domains.delete(old_domain_name)
       domains[params[:domain_name]] = params
       save_domains(domains)

       if params[:self_hosted]
         add_self_hosted_domain params
         rm_self_hosted_domain(old_domain_name)
         system_api.reload_dns
       end

       return true
     rescue  Exception=>e
     SystemUtils.log_exception(e)
       return false
     end
   end

   def add_self_hosted_domain params
     clear_error
     begin
#       p :Lachlan_Sent_parrams
#       p params

       return DNSHosting.add_hosted_domain(params,self)
       #       if ( DNSHosting.add_hosted_domain(params,self) == false)
       #         return false
       #       end
       #
       #     domains = load_self_hosted_domains()
       #       domains[params[:domain_name]] = params
       #
       return  save_self_hosted_domains(domains)
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def list_self_hosted_domains()
     clear_error
     begin
       return DNSHosting.load_self_hosted_domains()
       #        domains = load_self_hosted_domains()
       #        p domains
       #        return domains
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def  update_self_hosted_domain(old_domain_name, params)
     clear_error
     begin
       domains = load_self_hosted_domains()
       domains.delete(old_domain_name)
       domains[params[:domain_name]] = params
       save_self_hosted_domains(domains)
       return true
     rescue  Exception=>e
     SystemUtils.log_exception(e)
       return false
     end
   end

   def   remove_self_hosted_domain( domain_name)
     clear_error
     begin
       return DNSHosting.rm_hosted_domain(domain_name,self)
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

#   def save_system_preferences(preferences)
#     clear_error
#     begin
#       SystemUtils.debug_output("save prefs",preferences)
#       return true
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end
#
#   def load_system_preferences
#     clear_error
#     begin
#       SystemUtils.debug_output("load pres",:psdfsd)
#        
#     rescue  Exception=>e
#       SystemUtils.log_exception(e)
#       return false
#     end
#   end

   def get_container_memory_stats(container)
     clear_error
     ret_val= Hash.new
     begin
       if container && container.container_id == nil || container.container_id == '-1'
         container_id = read_container_id(container)
         container.container_id=(container_id)
       end
       if container && container.container_id != nil && container.container_id != '-1'
         path = "/sys/fs/cgroup/memory/docker/" + container.container_id + "/"
         if Dir.exists?(path)
           ret_val.store(:maximum , File.read(path + "/memory.max_usage_in_bytes"))
           ret_val.store(:current , File.read(path + "/memory.usage_in_bytes"))
           ret_val.store(:limit , File.read(path + "/memory.limit_in_bytes"))
         else
           p :no_cgroup_file
           p path
           ret_val.store(:maximum ,  "No Container")
           ret_val.store(:current , "No Container")
           ret_val.store(:limit ,  "No Container")
         end
       end

       return ret_val
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       ret_val.store(:maximum ,  e.to_s)
       ret_val.store(:current , "NA")
       ret_val.store(:limit ,  "NA")
       return ret_val
     end
   end

   def set_engine_network_properties(engine, params)
     clear_error
     begin
       engine_name = params[:engine_name]
       protocol = params[:http_protocol]
       if protocol.nil?
         p params
         return false
       end

       SystemUtils.debug_output("Changing protocol to _",  protocol )
       if protocol.include?("HTTPS only")
         engine.enable_https_only
       elsif protocol.include?("HTTP only")
         engine.enable_http_only
       elsif protocol.include?("HTTPS and HTTP")
         engine.enable_http_and_https
       end

       return true
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def set_engine_hostname_details(container,params)
     clear_error
     begin
       engine_name = params[:engine_name]
       hostname = params[:host_name]
       domain_name = params[:domain_name]

       SystemUtils.debug_output("Changing Domainame to " , domain_name)

       if container.hostname != hostname || container.domain_name != domain_name
         saved_hostName = container.hostname
         saved_domainName =  container.domain_name
         SystemUtils.debug_output("Changing Domainame to " , domain_name)

         if container.set_hostname_details(hostname,domain_name) == true
           nginx_service =  EnginesOSapi::ServicesModule.loadManagedService("nginx",self)
           nginx_service.remove_consumer(container)

           dns_service = EnginesOSapi::ServicesModule.loadManagedService("dns",self)
           dns_service.remove_consumer(container)

           dns_service.add_consumer(container)
           nginx_service.add_consumer(container)
           save_container(container)
         end

         return true
       end
       return true
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def get_system_memory_info
     clear_error
     ret_val = Hash.new
     begin
       proc_mem_info_file = File.open("/proc/meminfo")
       proc_mem_info_file.each_line  do |line|
         values=line.split(" ")
         case values[0]
         when "MemTotal:"
           ret_val[:total] = values[1]
         when "MemFree:"
           ret_val[:free]= values[1]
         when "Buffers:"
           ret_val[:buffers]= values[1]
         when "Cached:"
           ret_val[:file_cache]= values[1]
         when "Active:"
           ret_val[:active]= values[1]
         when "Inactive:"
           ret_val[:inactive]= values[1]
         when "SwapTotal:"
           ret_val[:swap_total]= values[1]
         when "SwapFree:"
           ret_val[:swap_free] = values[1]
         end
       end
       return ret_val
     rescue   Exception=>e
SystemUtils.log_exception(e)
       ret_val[:total] = e.to_s
       ret_val[:free] = -1
       ret_val[:active] = -1
       ret_val[:inactive] = -1
       ret_val[:file_cache] = -1
       ret_val[:buffers] = -1
       ret_val[:swap_total] = -1
       ret_val[:swap_free] = -1
       return ret_val
     end
   end

   def get_system_load_info
     clear_error
     ret_val = Hash.new

     begin
       loadavg_info = File.read("/proc/loadavg")
       values = loadavg_info.split(" ")
       ret_val[:one] = values[0]
       ret_val[:five] = values[1]
       ret_val[:fithteen] = values[2]
       run_idle = values[3].split("/")
       ret_val[:running] = run_idle[0]
       ret_val[:idle] = run_idle[1]
     rescue Exception=>e
SystemUtils.log_exception(e)
       ret_val[:one] = -1
       ret_val[:five] = -1
       ret_val[:fithteen] = -1
       ret_val[:running] = -1
       ret_val[:idle] = -1
       return ret_val

     rescue Exception=>e
SystemUtils.log_exception(e)
       return false
     end
   end

   def getManagedEngines()
     begin
       ret_val=Array.new
       Dir.entries(SysConfig.CidDir + "/containers/").each do |contdir|
         yfn = SysConfig.CidDir + "/containers/" + contdir + "/config.yaml"
         if File.exists?(yfn) == true
           managed_engine = loadManagedEngine(contdir)
           if managed_engine.is_a?(ManagedEngine)
             ret_val.push(managed_engine)
           else
             log_error("failed to load " + yfn)
           end
         end
       end
       return ret_val
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def loadManagedEngine(engine_name)
     if engine_name == nil || engine_name.length ==0
       last_error="No Engine Name"
       return false
     end
     begin
       yam_file_name = SysConfig.CidDir + "/containers/" + engine_name + "/config.yaml"

       if File.exists?(yam_file_name) == false
         log_error("no such file " + yam_file_name )
         return false # return failed(yam_file_name,"No such configuration:","Load Engine")
       end

       yaml_file = File.open(yam_file_name)
       managed_engine = ManagedEngine.from_yaml( yaml_file,@engines_api)

       if(managed_engine == nil || managed_engine == false)
         p :from_yaml_returned_nil
         return false # failed(yam_file_name,"Failed to Load configuration:","Load Engine")
       end
       return managed_engine

     rescue Exception=>e
       if engine_name != nil
         if managed_engine !=nil
           managed_engine.last_error=( "Failed To get Managed Engine " +  engine_name + " " + e.to_s)
           log_error(managed_engine.last_error)
         end
       else
         log_error("nil Engine Name")
       end
       SystemUtils.log_exception(e)
       return false
     end
   end

   def loadManagedService(service_name)
     begin
       if service_name == nil || service_name.length ==0
         last_error="No Service Name"
         return false
       end
       yam_file_name = SysConfig.CidDir + "/services/" + service_name + "/config.yaml"

       if File.exists?(yam_file_name) == false
         return false # return failed(yam_file_name,"No such configuration:","Load Service")
       end

       yaml_file = File.open(yam_file_name)
       # managed_service = YAML::load( yaml_file)
       managed_service = ManagedService.from_yaml(yaml_file,@engines_api)
       if managed_service == nil
         return false # return EnginsOSapiResult.failed(yam_file_name,"Fail to Load configuration:","Load Service")
       end

       return managed_service
     rescue Exception=>e
       if service_name != nil
         if managed_service !=nil
           managed_service.last_error=( "Failed To get Managed Engine " +  service_name + " " + e.to_s)
           log_error(managed_service.last_error)
         end
       else
         log_error("nil Service Name")
       end
       SystemUtils.log_exception(e)
       return false
     end
   end

   def getManagedServices()
     begin
       ret_val=Array.new
       Dir.entries(SysConfig.CidDir + "/services/").each do |contdir|
         yfn = SysConfig.CidDir + "/services/" + contdir + "/config.yaml"
         if File.exists?(yfn) == true
           yf = File.open(yfn)
           managed_service = ManagedService.from_yaml(yf,@engines_api)
           if managed_service
             ret_val.push(managed_service)
           end
           yf.close
         end
       end
       return ret_val
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end

   def list_managed_engines
     clear_error
     ret_val=Array.new
     begin
       Dir.entries(SysConfig.CidDir + "/containers/").each do |contdir|
         yfn = SysConfig.CidDir + "/containers/" + contdir + "/config.yaml"
         if File.exists?(yfn) == true
           ret_val.push(contdir)
         end
       end
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return ret_val
     end
     return ret_val
   end

   def list_managed_services
     clear_error

     ret_val=Array.new
     begin
       Dir.entries(SysConfig.CidDir + "/services/").each do |contdir|
         yfn = SysConfig.CidDir + "/services/" + contdir + "/config.yaml"
         if File.exists?(yfn) == true
           ret_val.push(contdir)
         end
       end
     rescue  Exception=>e
       SystemUtils.log_exception(e)
       return ret_val
     end
     return ret_val
   end

   def clear_container_var_run(container)
     clear_error
     begin
       dir = container_state_dir(container)
       #
       #remove startup only
       #latter have function to reset subs and other flags

       if File.exists?(dir + "/startup_complete")
         File.unlink(dir + "/startup_complete")
       end
       return true

     rescue Exception=>e
       SystemUtils.log_exception(e)
       return false
     end
   end
   

  
def generate_engines_user_ssh_key
  newkey = SystemUtils.run_command(SysConfig.generate_ssh_private_keyfile)
  if newkey.start_with?("-----BEGIN RSA PRIVATE KEY-----") == false
    last_error = res
    return false
  end
  return newkey
   rescue Exception=>e
     SystemUtils.log_exception(e)
     return false
   end
   
def system_update
  return SystemUtils.run_command("/opt/engines/bin/system_update.sh")
end
def container_state_dir(container)
    return SysConfig.CidDir + "/"  + container.ctype + "s/" + container.container_name
  end
   
   protected

   def container_cid_file(container)
     return  SysConfig.CidDir + "/"  + container.container_name + ".cid"
   end

  

   def container_log_dir container
     return SysConfig.SystemLogRoot + "/"  + container.ctype + "s/" + container.container_name
   end

   def run_system (cmd)
     clear_error
     begin
       cmd = cmd + " 2>&1"
       res= %x<#{cmd}>
       SystemUtils.debug_output("run System", res)
    
       #FIXME should be case insensitive The last one is a pure kludge
       #really need to get stderr and stdout separately
       if $? == 0 && res.downcase.include?("error") == false && res.downcase.include?("fail") == false && res.downcase.include?("could not resolve hostname") == false && res.downcase.include?("unsuccessful") == false
         return true
       else
         return res
       end
     rescue Exception=>e
       SystemUtils.log_exception(e)
       return ret_val
     end
   end

   def clear_error
     @last_error = ""
   end

   def  log_error(e_str)
     @last_error = e_str
     SystemUtils.log_output(e_str,10)
   end


 end #END of SystemApi
