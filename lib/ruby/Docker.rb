class Docker
  def initialize
    
  end
  
  def run_docker (args,container)
     ret_val=false
    container.set_last_result  ""           
     cmd="docker " + args + " 2>&1"           
     res= %x<#{cmd}>        
    # puts(cmd + "\n\n" + res)
          if $? == 0 && res.include?("Error") == false
              ret_val = true
            container.set_last_result res
          else                
            container.set_last_error  res;               
          end                 
      return ret_val
   end
   def run_system (cmd)
     cmd = cmd + " 2>&1"
     res= %x<#{cmd}>  
     p res
     #FIXME should be case insensitive The last one is a pure kludge
     #really need to get stderr and stdout separately
     if $? == 0 && res.include?("Error") == false && res.include?("Failed") == false && res.include?("Could not resolve hostname") == false && res.include?("unsuccessful") == false
       return true
     else
       return res
     end
    
        
   end
  def delete_image container
           commandargs= " rmi " +   container.image
           ret_val =  run_docker(commandargs,container)
           if ret_val == true             
                stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
                FileUtils.rm_rf  stateDir
          end
      return ret_val
   end
   
   def destroy_container container
     commandargs= " rm " +   container.containerName
     
     ret_val = run_docker(commandargs,container)      
     if (ret_val == true) #FIXME need to remove .cid if no such container but keep if container failed to stop
       if File.exists?(SysConfig.CidDir + "/" + container.containerName + ".cid") ==true
          File.delete(SysConfig.CidDir + "/" + container.containerName + ".cid")
       end
     end   
    return ret_val
     
   end
   
  def create_container container             
     e_option =String.new
      volume_option = String.new 
      eportoption = String.new
       if(container.environments)
         container.environments.each do |environment|
            if environment != nil                                                       
                   e_option = e_option + " -e " + environment.name + "=" + environment.value
            end
         end
       end
    volume_option=""
       if(container.volumes)
         container.volumes.each do |volume|
           if volume !=nil
    
             
             if volume.name == nil
               volume_name = ""
             else
               volume_name = volume.name 
             end

           if volume.localpath !=nil
               volume_option = volume_option + " -v " + volume.localpath + "/"  + volume_name + ":/" + volume.remotepath + "/" + volume_name + ":" + volume.mapping_permissions
             end
          end
         end
       end
       
       if(container.eports )
         container.eports.each do |eport|
           if eport != nil
         
             eportoption = eportoption +  " -p " + eport.port.to_s
               if eport.external >0
                 eportoption = eportoption + ":" + eport.external.to_s
               end
               if eport.proto_type == nil
                 eport.set_proto_type 'tcp'
               end
             eportoption = eportoption + "/"+ eport.proto_type + " "
           end
           end
       end
      
      if container.conf_self_start == false
        start_cmd=" /bin/bash /home/init.sh"
      else
        start_cmd=" "
      end
      commandargs =  " run -h " + container.hostName + e_option + " --memory=" + container.memory.to_s + "m " + volume_option + eportoption + " --cidfile " + SysConfig.CidDir + "/" + container.containerName + ".cid --name " + container.containerName + " -d  -t " + container.image + start_cmd                 
     puts commandargs
     cidfile = SysConfig.CidDir + "/"  + container.containerName + ".cid"
     if File.exists? cidfile
       File.delete cidfile
     end
     return  run_docker(commandargs,container)
   end
   
   def start_container   container      
     commandargs =" start " + container.containerName
     return  run_docker(commandargs,container)    
   end
   
   def stop_container container
     commandargs=" stop " + container.containerName
     return  run_docker(commandargs,container)
   end
   
   def pause_container container
     commandargs = " pause " + container.containerName
     return  run_docker(commandargs,container)    
   end
   
   def unpause_container container
      commandargs=" unpause " + container.containerName
     return  run_docker(commandargs,container)      
    end
    
   def ps_container container 
     commandargs=" top " + container.containerName + " axl"
     return  run_docker(commandargs,container)   
   end
   
   def logs_container container 
       commandargs=" logs " + container.containerName
       return  run_docker(commandargs,container)
     end
  
    def inspect_container container
       commandargs=" inspect " + container.containerName
      return  run_docker(commandargs,container)
    end
    
  def register_dns(top_level_hostname,ip_addr_str)  # no Gem made this simple (need to set tiny TTL) and and all used nsupdate anyhow
    fqdn_str = top_level_hostname + "." + SysConfig.internalDomain
    #FIXME need unique name for temp file
    dns_cmd_file_name="/tmp/.dns_cmd_file"
     dns_cmd_file = File.new(dns_cmd_file_name,"w+") 
     dns_cmd_file.puts("server " + SysConfig.defaultDNS)
    dns_cmd_file.puts("update delete " + fqdn_str)
    dns_cmd_file.puts("send")
    dns_cmd_file.puts("update add " + fqdn_str + " 30 A " + ip_addr_str)
    dns_cmd_file.puts("send")
    dns_cmd_file.close
    cmd_str = "nsupdate -k " + SysConfig.ddnsKey + " " + dns_cmd_file_name 
    retval = run_system(cmd_str) 
    File.delete(dns_cmd_file_name)
    return retval
  end
  
  def deregister_dns(top_level_hostname,ip_addr_str)
    fqdn_str = top_level_hostname + "." + SysConfig.internalDomain
        #FIXME need unique name
        dns_cmd_file_name="/tmp/.dns_cmd_file"
         dns_cmd_file = File.new(dns_cmd_file_name,"w") 
         dns_cmd_file.puts("server " + SysConfig.defaultDNS)
        dns_cmd_file.puts("update delete " + fqdn_str)
        dns_cmd_file.puts("send")
        dns_cmd_file.close
        cmd_str = "nsupdate -k " + SysConfig.ddnsKey + " " + dns_cmd_file_name 
        retval =  run_system(cmd_str)
        File.delete(dns_cmd_file_name)
        return retval
  end
  
  def register_site(site_string)      
      ssh_cmd=SysConfig.addSiteCmd + " \"" + site_string +  "\""
      return run_system(ssh_cmd)
  end
  
  def deregister_site(site_string)
     ssh_cmd=SysConfig.rmSiteCmd +  " \"" + site_string +  "\""
    return run_system(ssh_cmd)
  end
  
  def add_monitor(site_string)
    ssh_cmd=SysConfig.addSiteMonitorCmd + " \"" + site_string + " \""
    return run_system(ssh_cmd)
  end 
    
  def rm_monitor(site_string)
       ssh_cmd=SysConfig.rmSiteMonitorCmd + " \"" + site_string + " \""
    return run_system(ssh_cmd)
  end 
         
    def save_container container
      begin
        serialized_object = YAML::dump(container)       
            stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
              if File.directory?(stateDir) ==false
                Dir.mkdir(stateDir)
              end
            statefile=stateDir + "/config.yaml"              
            f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
            f.puts(serialized_object)
            f.close
            return true
          end
    rescue Exception=>e
      container.set_last_error e.message
      return false
    end
   
  def save_blueprint(blueprint,container)
     p container
     p blueprint
     if blueprint != nill
       puts blueprint.to_s
     end
        stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
                      if File.directory?(stateDir) ==false
                        Dir.mkdir(stateDir)
                      end
                    statefile=stateDir + "/blueprint.json"              
                    f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
                    f.write(blueprint.to_json)
                    f.close
      end 
    
  def load_blueprint(container)
          stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
                        if File.directory?(stateDir) ==false
                          Dir.mkdir(stateDir)
                        end
                      statefile=stateDir + "/blueprint.json"              
                      f = File.new(statefile,"r")
                      blueprint = f.read()
                      f.close
                      
                     return blueprint
        end    

end