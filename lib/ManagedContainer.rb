require 'fileutils'

require 'yaml'
require "rubygems"
require "json"
require "/opt/engos/lib/ruby/SysConfig.rb"
require "/opt/engos/lib/ruby/ContainerStatistics.rb"
require "/opt/engos/lib/ruby/ManagedContainerObjects.rb"
require "/opt/engos/lib/ruby/Container.rb"
require "/opt/engos/lib/ruby/Docker.rb"




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
        
        def set_last_result result
          @last_result = result
        end
        
        def set_last_error result
           @last_error = result
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
    
      #FIXME save or save_state ?  
      def save docker_api
        docker_api.save_container       
      end
      
  def save_state(docker_api)
     self.save docker_api
  end    
       
          
          def to_s
            "#{@containerName.to_s}, #{@ctype}, #{@memory}, #{@hostName}, #{@environments}, #{@image}, #{@volumes}, #{@port}, #{@eports}  \n"
          end


     def read_state docker_api
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
     
        def logs_container docker_api
          docker_api.logs_container self    
        end
        
        def ps_container get_docker_api 
          docker_api.ps_container self
            
        end
        
        def clear_error ret_val
            if ret_val==true
              @last_error=nil
            end
        end

        def delete_image docker_api
              ret_val=false
                state = read_state()
                        if state == "nocontainer"
                              ret_val=docker_api.delete_image self  
                         else    
                             @last_error ="Cannot Delete the Image while container exists\ Please stop/destroy first"
                        end
                clear_error(ret_val)        
                return ret_val      
        end

        def destroy_container docker_api
              ret_val=false
  
                state = read_state
                @setState="nocontainer" #this represents the state we want and not necessarily the one we get

                         if state == "stopped"
                                 ret_val=docker_api.destroy_container self  
                        else if state == "nocontainer"
                           @last_error ="No Active Container"                                         
                        else  
                         @last_error ="Cannot Destroy a container that is not stopped\nPlease stop first"                         
                         end                                 
                
                clear_error(ret_val)
                save_state(docker_api)
                return ret_val
             end
        end
  
           
        def create_container  docker_api 
          ret_val =false
          state = read_state
          
                       if state == "nocontainer"                             
                            ret_val = docker_api.create_container self 
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
          save_state(docker_api)
           return ret_val
        end
        
        
        def recreate_container docker_api
          ret_val =false
              if(retval=destroy_container(docker_api)) == true
                ret_val=create_container(docker_api)              
              end          
           
           return ret_val 
        end
    
  def unpause_container  docker_api
      state = read_state

      ret_val = false
              if state == "paused"
                @setState="running"
                ret_val= docker_api.unpause_container self                  
              else
                @last_error ="Can't unpause Container as " + state
              end

          clear_error(ret_val)
          save_state()
      return ret_val        
       
  end  
           
  def pause_container  docker_api
                state = read_state

                ret_val = false
                        if state == "running"
                          @setState="paused"
                          ret_val = docker_api.pause_container   self                      
                        else
                          @last_error ="Can't pause Container as " + state
                        end

              clear_error(ret_val)
              save_state(docker_api)
              return ret_val
   end

  def stop_container  docker_api    
      ret_val = false
      state = read_state
                  
        if state== "running"
          ret_val = docker_api.stop_container   self 
          @setState="stopped"
        else  
          @last_error ="Can't stop Container as " + state
        end
      
      clear_error(ret_val)
      save_state(docker_api) 
      return  ret_val
    end
   
              
        def start_container docker_api
          ret_val=false
          state = read_state

             
            if state == "stopped"
               ret_val = docker_api.start_container self
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
          save_state(docker_api)
          return ret_val  
        end
           
        def restart_container docker_api
          ret_val=false
             if (ret_val = stop_container docker_api ) == true
                  ret_val = start_container docker_api     
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
       
       def stats docker_api
        
         inspect_container docker_api
         
         output = JSON.parse(last_result)
         started = output[0]["State"]["StartedAt"]
         stopped = output[0]["State"]["FinishedAt"]
         state = read_state
          
        ps_container  docker_api
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
       
       def status docker_api
         s = read_state()      
        # puts s 
       end  
         
       def slast_error
         return @last_error
       end
       
       def last_result
         return @last_result
       end
     
       def inspect_container  docker_api     
            ret_val = docker_api.inspect_container self                                                                              
           return ret_val
       end
                                             
end


