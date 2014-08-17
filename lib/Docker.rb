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
     if (ret_val == true)
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
       if(container.volumes)
         container.volumes.each do |volume|
             if volume.name !=nil
               volume_option = volume_option + " -v " + volume.localpath + "/"  + volume.name + ":" + volume.remotepath + "/" + volume.name
             end
         end
       end
       
       if(container.eports )
         container.eports.each do |eport|
             eportoption = eportoption +  " -p " + eport.port.to_s
               if eport.external >0
                 eportoption = eportoption + ":" + eport.external.to_s + " "
               end
           end
       end
      
 
      commandargs =  " run -h " + container.hostName + e_option + " --memory=" + container.memory.to_s + "m " + volume_option + eportoption + " --cidfile " + SysConfig.CidDir + "/" + container.containerName + ".cid --name " + container.containerName + " -d  -t " + container.image       + " /bin/bash /home/init.sh"                 
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
    
    def save_container container
      serialized_object = YAML::dump(container)  
      save_serialized(serialized_object,container)
    end       
      
  def   save_serialized(serialized_object,container)
            stateDir=SysConfig.CidDir + "/"  + container.ctype + "s/" + container.containerName
              if File.directory?(stateDir) ==false
                Dir.mkdir(stateDir)
              end
            statefile=stateDir + "/config.yaml"
              
            f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
            f.puts(serialized_object)
            f.close
          end

end