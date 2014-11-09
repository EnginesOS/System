require 'fileutils'

require 'yaml'
require "rubygems"
require "json"
require "/opt/engines/lib/ruby/SysConfig.rb"
require "/opt/engines/lib/ruby/ContainerStatistics.rb"
require "/opt/engines/lib/ruby/ManagedContainerObjects.rb"
require "/opt/engines/lib/ruby/Container.rb"
require "/opt/engines/lib/ruby/Docker.rb"

require 'objspace'


class ManagedContainer < Container
  @conf_self_start=false
  @conf_register_dns=true
  @conf_register_site=false
  @conf_monitor_site=false
  @http_and_https=true
  @https_only=false
  
 def initialize(mem,name,host,domain,image,e_ports,vols,environs,framework,runtime,databases,setState,port,repo) #used for test only
   @framework = framework
   @runtime = runtime
   @databases = databases
   @setState = setState
   @port = port
   @repo = repo
   @last_error = last_error
   @memory = mem
   @containerName = name
   @hostName = host
   @domainName = domain
   @image = image
   @eports = e_ports
   @volumes = vols
   @environments = environs
   @conf_self_start=false
   @conf_register_dns=true #do this even if self registers dns s it dd to the dns consumer (so record survives rebuild)
   @conf_register_site=false
   @conf_monitor_site=false
   @http_and_https=true
   @https_only=false
   @last_error=""
   @last_result=""
   
   @cont_userid=-1
#   @ro_groupid
#   @rw_groupid
      
 end
 
 def container_pid
   if @container_pid == nil
     @container_pid = set_container_pid
      if @container_pid == false
        @container_pid == "-1"
      end            
   end
   p @container_pid
   return @container_pid
 end
 
 def http_and_https
   @http_and_https
 end
 def https_only
   @https_only
 end
 
  def docker_api 
    return @docker_api
  end
  
  def conf_self_start
    return @conf_self_start
  end
  
  def conf_register_dns
    @conf_register_dns
  end
  
  def conf_register_site
    return @conf_register_site
  end
  
  def set_conf_register_site state
    @conf_register_site = state
  end
  def set_conf_self_start state
    @conf_self_start = state
     end
  def conf_monitor_site
    return @conf_monitor_site
  end
  
  def framework
    return @framework
  end

  def runtime
    return @runtime
  end

  def monitored
    return @conf_monitor_site
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

  def last_error
    return @last_error
  end

  def ManagedContainer.from_yaml( yaml )
    managedContainer = YAML::load( yaml )
    managedContainer
  end

  def set_docker_api docker_api
    @docker_api = docker_api
  end

  def to_s
    "#{@containerName.to_s}, #{@ctype}, #{@memory}, #{@hostName}, #{@self_start}, #{@environments}, #{@image}, #{@volumes}, #{@port}, #{@eports}  \n"
  end

  def read_state()
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
      if    @last_error == nil
        @last_error=""
      end
     @last_error =  @last_error + " Warning State Mismatch set to " + @setState + " but in " + state + " state"
    end
    return state
  end

  def logs_container    
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    return @docker_api.logs_container(self)
  end

  def ps_container
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    return @docker_api.ps_container(self)

  end

  def delete_image
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val=false
    state = read_state()
    if state == "nocontainer"
      ret_val=@docker_api.delete_image self
    else
      @last_error ="Cannot Delete the Image while container exists. Please stop/destroy first"
    end
    clear_error(ret_val)
    return ret_val
  end

  def destroy_container
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val=false

    state = read_state
    @setState="nocontainer" #this represents the state we want and not necessarily the one we get

    if state == "stopped"
      ret_val=@docker_api.destroy_container self
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
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val =false
    state = read_state()

    if state == "nocontainer"
      ret_val = @docker_api.create_container self
      @setState="running"
    else
      @last_error ="Cannot create container if container by the same name exists"
    end
    if ret_val == true
      if conf_register_dns == true
          register_dns
        end
      if conf_register_site == true
        register_site
      end
      if read_state != "running"
        ret_val = false
      end
    end
    clear_error(ret_val)
    save_state()
    set_container_pid
    
    return ret_val
  end

  def recreate_container
    ret_val =false
    if(retval=destroy_container()) == true
      ret_val=create_container()
    end

    return ret_val
  end

  def unpause_container
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    state = read_state()

    ret_val = false
    if state == "paused"
      @setState="running"
      ret_val= @docker_api.unpause_container self
    else
      @last_error ="Can't unpause Container as " + state
    end

    clear_error(ret_val)
    save_state()
    return ret_val

  end

  def pause_container
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    state = read_state()

    ret_val = false
    if state == "running"
      @setState="paused"
      ret_val = @docker_api.pause_container self
    else
      @last_error ="Can't pause Container as " + state
    end

    clear_error(ret_val)
    save_state()
    return ret_val
  end

  def stop_container
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val = false
    state = read_state()
    @set_container_pid="-1"
    
    if state== "running"
      ret_val = @docker_api.stop_container   self
      deregister_registered
      
      @setState="stopped"
    else
      @last_error ="Can't stop Container as " + state
      if state != "paused" #force deregister if stopped or no container etc
           deregister_registered
         end
    end
   
    clear_error(ret_val)
    save_state()
    return  ret_val
  end
  
  def deregister_registered
    if @conf_register_site == true
           deregister_site
          end
          if @conf_register_dns == true
            deregister_dns
          end
  end

  def start_container
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val=false
    state = read_state()

    if state == "stopped"
      ret_val = @docker_api.start_container self
      @setState="running"
    else
      @last_error ="Can't Start Container as " + state
    end

    if ret_val == true
       if @conf_register_dns ==true
         register_dns
      end
        if @conf_register_site == true
          register_site
        end
    end

    clear_error(ret_val)
    save_state()
    return ret_val
  end

  def restart_container
    ret_val=false
    if (ret_val = stop_container  ) == true
      ret_val = start_container        
    end
    return ret_val
  end

  def register_site
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    if is_active == true 
      service =  EnginesOSapi.loadManagedService("nginx",@docker_api)
      return service.add_consumer(self)
     else
            @last_error="Cannot register when Engine is inactive"
            return false
      end    
  end

  def monitor_site
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    service =  EnginesOSapi.loadManagedService("monit",@docker_api)
    return service.add_consumer(self)
  end

  def deregister_site
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    service =  EnginesOSapi.loadManagedService("nginx",@docker_api)
    return service.remove_consumer(self)
  end

  def demonitor_site
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
  
      service =  EnginesOSapi.loadManagedService("monit",@docker_api)
      return service.remove_consumer(self)
   
  end
  
  def register_dns 
    if @docker_api == nil
       @last_error="No connection to Engines OS System"      
       return false
     end
     
     if is_active == true        
      service =  EnginesOSapi.loadManagedService("dns",@docker_api)
      return service.add_consumer(self)
     else
       @last_error="Cannot register when Engine is inactive"
       return false
     end   
  end
  
  def deregister_dns
    if @docker_api == nil
       @last_error="No connection to Engines OS System"      
       return false
     end
     service =  EnginesOSapi.loadManagedService("dns",@docker_api)
    return service.remove_consumer(self)

  end

  def get_ip_str
    if inspect_container == false
      return false
    end
    output = JSON.parse(@last_result)
    ip_str=output[0]['NetworkSettings']['IPAddress']
  #    puts containerName + ":" + ip_str
      return ip_str
  end
  
  
  def register
    register_site
    monitor_site
    #FIXME check results
  end

  def stats

    if inspect_container() == false
      return false
    end

    output = JSON.parse(last_result)
    started = output[0]["State"]["StartedAt"]
    stopped = output[0]["State"]["FinishedAt"]
    state = read_state()

    ps_container()
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


  def last_result
    return @last_result
  end

  def inspect_container
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val = @docker_api.inspect_container self
    return ret_val
  end

  def save_state()
    if @docker_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    trim_last_result
    trim_last_error
#    puts("engine usage")
#    p ObjectSpace.memsize_of(self)
#    puts("all managedContainers")
#
#        p ObjectSpace.memsize_of(self)
#    puts(" managed engin total")     
#    p ObjectSpace.memsize_of_all(ManagedContainer)
#
#    puts("api usage")
#    p ObjectSpace.memsize_of(@docker_api)
    
    
    ret_val = @docker_api.save_container self
    return ret_val
  end
  
  def save_blueprint blueprint
    if @docker_api == nil
         @last_error="No connection to Engines OS System"      
         return false
       end
       ret_val = @docker_api.save_blueprint(blueprint, self)
       return ret_val
  end
  
  def load_blueprint
    if @docker_api == nil
            @last_error="No connection to Engines OS System"      
            return false
          end
          ret_val = @docker_api.load_blueprint(self)
          return ret_val
  end
  
  def rebuild_container
    if @docker_api == nil
          @last_error="No connection to Engines OS System"      
           return false
     end
    ret_val = @docker_api.rebuild_image(self)
    return ret_val
  end
def is_running
   state = read_state
  if state == "running"
     return true
  else
    return false
  end
end
     
def is_startup_complete
    if @docker_api == nil
           @last_error="No connection to Engines OS System"      
            return false
     end
     ret_val = @docker_api.is_startup_complete(self)
    return ret_val
end
  
  def is_active
    state = read_state
   case state
    when "running"
      return true
    when "paused"
      return true
    else
      return false
   end  
  end
  
  def enable_https
    http_and_https=true
     https_only = false
    register_site
     save_state
  end
  
  def disable_https
    http_and_https=false
    https_only = false
    register_site
    save_state
  end
  
  def enable_httpsonly
    https_only = true
    http_and_https=false
    register_site
    save_state
  end
  
 def disable_httpsonly
   https_only = false
   http_and_https=true
   register_site
   save_state
 end
  

  protected
  
def trim_last_result
  if @last_result.is_a?(String) && @last_result.length >256
    @last_result=@last_result.slice!(0,256)
  end
end
def trim_last_error
  if  @last_error.is_a?(String) && @last_error.length >256
    @last_error=@last_error.slice!(0,256)
  end
end

  def clear_error ret_val
    if ret_val==true
      @last_error=nil
    end
  end

    def set_container_pid
   return "-1"  
   
      
    end
    
end

