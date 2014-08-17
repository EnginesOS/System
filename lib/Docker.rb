class Docker
  def initialize
    
  end
  
  def run_docker (args)
     ret_val=false
     @last_result = ""           
     cmd="docker " + args + " 2>&1"           
     res= %x<#{cmd}>        
    # puts(cmd + "\n\n" + res)
          if $? == 0 && res.include?("Error") == false
              ret_val = true
              @last_result = res
          else                
              @last_error = res;               
          end            
     
      return ret_val
   end
   
  def delete_image container
           commandargs= " rmi " +   container.image
           return  run_docker(commandargs)                
   end
   
   def destroy_container container
     commandargs= " rm " +   container.containerName
     
     return  run_docker(commandargs)      
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
     return  run_docker(commandargs)
   end
   
   def start_container   container      
     commandargs =" start " + container.containerName
 
     return  run_docker(commandargs)
     
   end
   
   def stop_container container
     commandargs=" stop " + container.containerName

     return  run_docker(commandargs)
   end
   
   def pause_container container
     commandargs = " pause " + container.containerName

     return  run_docker(commandargs)    
   end
   
   def unpause_container container
      commandargs=" unpause " + container.containerName

     return  run_docker(commandargs)      
    end
    
   def ps_container container 
     commandargs=" top " + container.containerName + " axl"

     return  run_docker(commandargs)   
   end
   
   def logs_container container 
       commandargs=" logs " + container.containerName

       return  run_docker(commandargs)
     end
  
    def inspect_container container
       commandargs=" inspect " + container.containerName

      return  run_docker(commandargs)
    end

end