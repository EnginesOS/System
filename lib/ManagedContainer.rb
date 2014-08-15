require 'fileutils'

require 'yaml'
require "rubygems"
require "json"
require "/opt/engos/lib/ruby/SysConfig.rb"
require "/opt/engos/lib/ruby/ContainerStatistics.rb"
require "/opt/engos/lib/ruby/ManagedContainerObjects.rb"
require "/opt/engos/lib/ruby/Container.rb"



class ManagedContainer < Container
                
        def framework
          return @framework
        end
        
        def runtime
          return @runtime
        end
         
        def monitored
            return @monitored
        end
        
        def databases
          return @databases
        end

        def setState
          return @setState
        end
        

        def port
          return @port
        end
     
        def repo
          return @repo
        end
        
 
        
        def self.from_yaml( yaml )
          managedContainer = YAML::load( yaml )
          managedContainer
    end
    
    def ManagedContainer.load(type,name)
      yam_file_name = SysConfig.CidDir + "/" + type + "s/" + name + "/config.yaml"
     
        if File.exists?(yam_file_name) == false
          puts("No such configuration:" + yam_file_name )
          return nil
        end 
        
      yaml_file = File.open(yam_file_name) 
      managedContainer = YAML::load( yaml_file)
      managedContainer
    end

      def ManagedContainer.getManagedContainers(type)
        ret_val=Array.new
           Dir.entries(SysConfig.CidDir + "/" + type + "s/").each do |contdir|
             yfn = SysConfig.CidDir + "/" + type + "s/" + contdir + "/config.yaml"     
             if File.exists?(yfn) == true           
               yf = File.open(yfn)   
               cont = ManagedContainer.from_yaml(yf)
               if cont                 
                 ret_val.push(cont)
               end
               yf.close
             end
           end
           return ret_val
      end
      
      def save
        serialized_object = YAML::dump(self)  
        save_serialized(serialized_object)
      end
      
       def   save_serialized(serialized_object)
          stateDir=SysConfig.CidDir + "/"  + @ctype + "s/" + @containerName
            if File.directory?(stateDir) ==false
              Dir.mkdir(stateDir)
            end
          statefile=stateDir + "/config.yaml"
            
          f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
          f.puts(serialized_object)
          f.close
        end
          
          def to_s
            "#{@containerName.to_s}, #{@ctype}, #{@memory}, #{@hostName}, #{@environments}, #{@image}, #{@volumes}, #{@port}, #{@eports}  \n"
          end
#DOCKER Wrappers to be moved to new class
          
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
         
        def docker_delete_image
                commandargs= " rmi " +   @image
                return  run_docker(commandargs)                
        end
        
        def docker_destroy_container
          commandargs= " rm " +   @containerName
          
          return  run_docker(commandargs)      
        end
        
        def docker_create_container 
     
          
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
        
        def docker_start_container        
          commandargs =" start " + @containerName
      
          return  run_docker(commandargs)
          
        end
        
        def docker_stop_container
          commandargs=" stop " + @containerName

          return  run_docker(commandargs)
        end
        
        def docker_pause_container
          commandargs = " pause " + @containerName

          return  run_docker(commandargs)    
        end
        
        def docker_unpause_container
           commandargs=" unpause " + @containerName

          return  run_docker(commandargs)      
         end
         
        def docker_ps_container
          commandargs=" top " + @containerName + " axl"
   
          return  run_docker(commandargs)   
        end
        
        def docker_logs_container
            commandargs=" logs " + @containerName

            return  run_docker(commandargs)
          end
       
         def docker_inspect_container
            commandargs=" inspect " + @containerName

           return  run_docker(commandargs)
         end

#Functions replicated/ported from /opt/engos/etc/functions.sh
 
  
        def write_state(stateDir,state)
                statefile=stateDir + "/state"
                f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
                f.puts(state)
                f.close
                #puts "state " + state
        end

        def save_state()#state)
           self.save
        #    stateDir=@CidDir + "/"  + @ctype + "s/" + @containerName       
         #       if File.directory?(stateDir) == true
          #          write_state(stateDir,state)
           #     else if state != "nocontainer"
            #        Dir.mkdir(stateDir)
             #       write_state(stateDir,state)
              #  end
               #end
        end 
        
        
        def oread_state
                 stateDir=SysConfig.CidDir + "/"  + @ctype + "s/" + @containerName
                        if File.directory?(stateDir) == false
                                return "nocontainer"
                        end

                statefile=stateDir  + "/state"
                  if File.file?(statefile)
                    f = File.open(statefile,"r")
                    state = f.gets
                    f.close
                  else
                      state = "nocontainer"
                  end
                return state.chomp
        end

     def read_state 
          if (inspect_container == false)
              state="nocontainer"
            else     
              output = JSON.parse(last_result)
                if output[0]["State"]    
                    if output[0]["State"]["Running"] == true
                        state = "running"
                            if output[0]["State"]["Paused"] == true
                                state= "paused"
                            end
                    elsif     output[0]["State"]["Running"] == false                              
                          state = "stopped"
                    else
                        state="nocontainer"           
                    end
                end
          end
          if (@setState && state != @setState)
            puts( "Warning State Mismatch set to " + @setState + " but in " + state + " state")
            
          end
         return state
     end
     
        def logs_container
            docker_logs_container         
        end
        
        def ps_container
            docker_ps_container
            
        end
        
        def clear_error ret_val
            if ret_val==true
              @last_error=nil
            end
        end

        def delete_image
              ret_val=false
                state = read_state()
                        if state == "nocontainer"
                                if (ret_val=docker_delete_image()) == true
                                        stateDir=SysConfig.CidDir + "/"  + @ctype + "s/" + @containerName
                                        FileUtils.rm_rf  stateDir
                                        ret_val = true
                                end
                        else
                                @last_error ="Cannot Delete the Image while container exists\ Please stop/destroy first"
                        end
                clear_error(ret_val)        
                return ret_val      
        end

        def destroy_container
              ret_val=false
  
                state = read_state
                @setState="nocontainer" #this represents the state we want and not necessarily the one we get

                         if state == "stopped"
                                 ret_val=docker_destroy_container()  
                                         if (ret_val == true)
                                           if File.exists?(SysConfig.CidDir + "/" + @containerName + ".cid") ==true
                                              File.delete(SysConfig.CidDir + "/" + @containerName + ".cid")
                                           end
                                         end
                        else if state == "nocontainer"
                           @last_error ="No Active Container"    
                                     
                        else  
                         @last_error ="Cannot Destroy a container that is not stopped\nPlease stop first"                         
                         end                                 
                
                clear_error(ret_val)
                save_state()
                return ret_val
             end
        end
  
           
        def create_container 
          ret_val =false
          state = read_state
          
                       if state == "nocontainer"                             
                            ret_val = docker_create_container
                             @setState="running"                              
                       else
                         @last_error ="Cannot create container if container by the same name exists"
                       end
                  if ret_val == true
                    if @registersite == true
                      register_site
                    end
                  end          
          clear_error(ret_val)
          save_state()
           return ret_val
        end
        
        
        def recreate_container
          ret_val =false
              if(retval=destroy_container) == true
                ret_val=create_container               
              end          
           
           return ret_val 
        end
    
  def unpause_container 
      state = read_state

      ret_val = false
              if state == "paused"
                @setState="running"
                ret_val= docker_unpause_container                
              else
                @last_error ="Can't unpause Container as " + state
              end

          clear_error(ret_val)
          save_state()
      return ret_val        
       
  end  
           
  def pause_container 
                state = read_state

                ret_val = false
                        if state == "running"
                          @setState="paused"
                          ret_val = docker_pause_container                        
                        else
                          @last_error ="Can't pause Container as " + state
                        end

              clear_error(ret_val)
              save_state()
              return ret_val
   end

  def stop_container      
      ret_val = false
      state = read_state
                  
        if state== "running"
          ret_val = docker_stop_container   
          @setState="stopped"
        else  
          @last_error ="Can't stop Container as " + state
        end
      
      clear_error(ret_val)
      save_state() 
      return  ret_val
    end
   
              
        def start_container
          ret_val=false
          state = read_state

             
            if state == "stopped"
               ret_val = docker_start_container
              @setState="running"                                               
             else
                @last_error ="Can't Start Container as " + state
             end
             
            if ret_val == true
              if @registersite == true
                     register_site
               end
            end
             
          
          clear_error(ret_val)
          save_state()
          return ret_val  
        end
           
        def restart_container
          ret_val=false
             if (ret_val = stop_container) == true
                  ret_val = start_container     
             else 
               @last_error ="Fail to Stop Container "
             end
         
           return ret_val  
        end

       def register_site
         service =  NginxService.load("nginx")       
        return service.add_consumer(self)                
       end
       
       def monitor_site
         service =  NagiosService.load("monit")       
            return service.add_consumer(self)  
       end
       
       def deregister_site
         service =  NginxService.load("nginx")       
         return service.remove_consumer(self) 
       end
        
       def demonitor_site
         service =  NagiosService.load("monit")       
         return service.remove_consumer(self)          
       end
       
       def register
         register_site
         monitor_site
         #FIXME check results
       end
       
       def stats
        
         inspect_container
         
         output = JSON.parse(last_result)
         started = output[0]["State"]["StartedAt"]
         stopped = output[0]["State"]["FinishedAt"]
         state = read_state
          
         docker_ps_container
         pcnt=-1
         rss=0 
         vss=0
         h=m=s=0
         
         @last_result.each_line.each do |line|
           if pcnt >0 #skip the fist line with is a header                        
        
           
           fields =  line.split()  #  [6]rss [10] time
              if fields != nil
                 rss += fields[7].to_i
                 vss += fields[6].to_i
                time_f = fields[11]
                c_HMS = time_f.split(':')
               
                  if c_HMS.length == 3
                    h+= c_HMS[0].to_i
                    m+=c_HMS[1].to_i
                    s+=c_HMS[2].to_i
                  else
                    m+=c_HMS[0].to_i
                    s+=c_HMS[1].to_i
                 end
             end
   
           end
           pcnt=pcnt+1
         end                 
          cpu = 3600 * h + 60 * m + s
          statistics = ContainerStatistics.new(state,pcnt,started,stopped,rss,vss,cpu)
          return statistics
       end
       
       def status
         s = read_state()      
        # puts s 
       end  
         
       def slast_error
         return @last_error
       end
       
       def last_result
         return @last_result
       end
     
       def inspect_container

            ret_val = docker_inspect_container                                                                            
                            
           return ret_val
       end
                                             
end


