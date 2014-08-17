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
   
  def delete_image
           commandargs= " rmi " +   @image
           return  run_docker(commandargs)                
   end
   
   def destroy_container
     commandargs= " rm " +   @containerName
     
     return  run_docker(commandargs)      
   end
   
  def create_container              
     e_option =String.new
      volume_option = String.new 
      eportoption = String.new
       if(@environments)
          @environments.each do |environment|
            if environment != nil                                                       
                   e_option = e_option + " -e " + environment.name + "=" + environment.value
            end
         end
       end
       if(@volumes)
         @volumes.each do |volume|
             if volume.name !=nil
               volume_option = volume_option + " -v " + volume.localpath + "/"  + volume.name + ":" + volume.remotepath + "/" + volume.name
             end
         end
       end
       
       if(@eports )
           @eports.each do |eport|
             eportoption = eportoption +  " -p " + eport.port.to_s
               if eport.external >0
                 eportoption = eportoption + ":" + eport.external.to_s + " "
               end
           end
       end
      
 
      commandargs =  " run -h " + @hostName + e_option + " --memory=" + @memory.to_s + "m " + volume_option + eportoption + " --cidfile " + SysConfig.CidDir + "/" + @containerName + ".cid --name " + @containerName + " -d  -t " + @image       + " /bin/bash /home/init.sh"                 
     puts commandargs
     cidfile = SysConfig.CidDir + "/"  + @containerName + ".cid"
     if File.exists? cidfile
       File.delete cidfile
     end
     return  run_docker(commandargs)
   end
   
   def start_container        
     commandargs =" start " + @containerName
 
     return  run_docker(commandargs)
     
   end
   
   def stop_container
     commandargs=" stop " + @containerName

     return  run_docker(commandargs)
   end
   
   def pause_container
     commandargs = " pause " + @containerName

     return  run_docker(commandargs)    
   end
   
   def unpause_container
      commandargs=" unpause " + @containerName

     return  run_docker(commandargs)      
    end
    
   def ps_container
     commandargs=" top " + @containerName + " axl"

     return  run_docker(commandargs)   
   end
   
   def logs_container
       commandargs=" logs " + @containerName

       return  run_docker(commandargs)
     end
  
    def inspect_container
       commandargs=" inspect " + @containerName

      return  run_docker(commandargs)
    end

end