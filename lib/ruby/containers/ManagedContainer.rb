require 'fileutils'

require 'yaml'
require "rubygems"
require "json"
require "/opt/engines/lib/ruby/system/SysConfig.rb"
require_relative "ContainerStatistics.rb"
require_relative "ManagedContainerObjects.rb"
require_relative "Container.rb"
require "/opt/engines/lib/ruby/api/system/EnginesCore.rb"

require 'objspace'


class ManagedContainer < Container
  @conf_self_start=false
  @conf_register_dns=true
  @conf_register_site=false
  @conf_monitor_site=false
  @http_and_https=true
  @https_only=false
  
 def initialize(mem,name,host,domain,image,e_ports,vols,environs,framework,runtime,databases,setState,port,repo,data_uid,data_gid) #used for test only
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
#   @http_and_https=true
#   @https_only=false
   @last_error=""
   @last_result=""
   @data_uid=data_uid
   @data_gid=data_gid
   @cont_userid=-1
   @protocol=:http_and_https
 end
 
 
 
 def container_id
   if @container_id == nil
     @container_id = set_container_id
      if @container_id == false
        @container_id == "-1"
      end            
   end
   p @container_id
   return @container_id
 end
 
  attr_reader :framework,\
              :runtime,\
              :databases,\
              :port,\
              :repo,\
              :data_uid,\
              :data_gid,\
              :cont_userid,\
              :setState,\
              :protocol,\
              :volumes

   attr_accessor :container_id,\
                  :core_api,\
                  :conf_self_start,\
                  :conf_register_site,\
                  :conf_register_dns,\
                  :conf_monitor_site,\
                  :last_result,\
                  :last_error
                  
  def cron_job_list
    if @cron_job_list == nil
      @cron_job_list =  Array.new
    end
    return @cron_job_list
  end
                  
   def set_cron_job_list(job_list)
     @cron_job_list = job_list 
     p :set_cron_job_list
     p @cron_job_list
         
   end
  
def http_protocol
  case @protocol
  when :http_and_https
    return "HTTPS and HTTP"
  when :http_only
    return "HTTP only"
  when :https_only
    return "HTTPS only"
  end
  p "no web protocol err"
  return "HTTP only"
end

def set_protocol(proto)
  case proto
  when "HTTPS and HTTP"
    enable_http_and_https
  when "HTTP only"
    enable_http_only
  when "HTTPS only"
    enable_httpd_only
  end
end
  def monitored
    return conf_monitor_site
  end
 
  def ManagedContainer.from_yaml( yaml, core_api )
    managedContainer = YAML::load( yaml )
    managedContainer.core_api = core_api
    managedContainer
  end



  def to_s
    "#{@containerName.to_s}, #{@ctype}, #{@memory}, #{@hostName}, #{@self_start}, #{@environments}, #{@image}, #{@volumes}, #{@port}, #{@eports}  \n"
  end

  @res
  def read_state()
    begin
    if (inspect_container == false)
      state="nocontainer"
    else
      @res= last_result
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
    if state == nil #Kludge
      state = "nocontainer"
    end
    if (@setState && state != @setState)  
      if    @last_error == nil
        @last_error=" "
      end

     @last_error =  @last_error + " Warning State Mismatch set to " + @setState + " but in " + state + " state"
    end
    return state


rescue Exception=>e
   p :json_Str
   p @res
SystemUtils.log_exception(e)
  return "nocontainer"
end
end

  def logs_container    
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    return @core_api.logs_container(self)
  end

  def ps_container
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    return @core_api.ps_container(self)

  end

  def delete_image()
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val=false
    state = read_state()
    if state == "nocontainer"
      ret_val=@core_api.delete_image(self)
    else
      @last_error ="Cannot Delete the Image while container exists. Please stop/destroy first"
    end
    clear_error(ret_val)
    return ret_val
  end

  def destroy_container
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val=false

    state = read_state
    @setState="nocontainer" #this represents the state we want and not necessarily the one we get

    if state == "stopped"
      ret_val=@core_api.destroy_container self
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

   def setup_container
     if @core_api == nil
       @last_error="No connection to Engines OS System"      
       return false
     end
     ret_val =false
     state = read_state()
 
     if state == "nocontainer"
       ret_val = @core_api.setup_container self
       @setState="stopped"
     else
       @last_error ="Cannot create container if container by the same name exists"
     end
    
     clear_error(ret_val)
     save_state()
  
     
     return ret_val
   end
   
  def create_container
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val =false
    state = read_state()

    if state == "nocontainer"
      ret_val = @core_api.create_container self
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
        @last_error ="Did not start"
        ret_val = false
      end
    end
    clear_error(ret_val)
    save_state()
    set_container_id
    
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
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    state = read_state()

    ret_val = false
    if state == "paused"
      @setState="running"
      ret_val= @core_api.unpause_container self
    else
      @last_error ="Can't unpause Container as " + state
    end

    clear_error(ret_val)
    save_state()
    return ret_val

  end

  def pause_container
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    state = read_state()

    ret_val = false
    if state == "running"
      @setState="paused"
      ret_val = @core_api.pause_container self
    else
      @last_error ="Can't pause Container as " + state
    end

    clear_error(ret_val)
    save_state()
    return ret_val
  end

  def stop_container
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val = false
    state = read_state()
    @set_container_id="-1"
    
    if state== "running"
      ret_val = @core_api.stop_container   self
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
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val=false
    state = read_state()

    if state == "stopped"
      ret_val = @core_api.start_container self
      @setState="running"
       
    else
      @last_error ="Can't Start Container as " + state
    end
    if ret_val == true
      register
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
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    if conf_register_site == false
      return true
    end
    
    if is_active == true  
      service =  EnginesOSapi.loadManagedService("nginx",@core_api)
      return service.add_consumer(self)
     else
            @last_error="Cannot register when Engine is inactive"
            return false
      end    
  end

  def monitor_site
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    service =  EnginesOSapi.loadManagedService("monit",@core_api)
      if service.is_a?(ManagedService)
      return service.add_consumer(self)
    end
    return false
  end

  def deregister_site
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    service =  EnginesOSapi.loadManagedService("nginx",@core_api)
    if service.is_a?(ManagedService)
    return service.remove_consumer(self)
    end
    return false
  end

  def demonitor_site
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end  
      service =  EnginesOSapi.loadManagedService("monit",@core_api)
      return service.remove_consumer(self)   
  end
  
  def register_dns 
    if @core_api == nil
       @last_error="No connection to Engines OS System"      
       return false
     end
     
     if is_active == true        
      service =  EnginesOSapi.loadManagedService("dns",@core_api)
      return service.add_consumer(self)
     else
       @last_error="Cannot register when Engine is inactive"
       return false
     end   
  end
  
  def deregister_dns
    if @core_api == nil
       @last_error="No connection to Engines OS System"      
       return false
     end
     service =  EnginesOSapi.loadManagedService("dns",@core_api)
     if service.is_a?(ManagedService) == false
       p failed_to_load_dns_service
       return false
     else
    return service.remove_consumer(self)
     end
  end

  def get_ip_str
    if inspect_container == false
      return false
    end
    output = JSON.parse(@last_result)
    ip_str=output[0]['NetworkSettings']['IPAddress']
  #    puts containerName + ":" + ip_str
      return ip_str
  rescue 
        return nil
  end
  
  
  def register
   
         if @conf_register_dns ==true
           register_dns
        end
          if @conf_register_site == true
            register_site
          end
      
        if @conf_monitor_site == true
          monitor_site
        end
    cron_service = @core_api.loadManagedService("cron")       
    cron_job_list.each do |cj|
      p :register_cj
      p cj        
       cron_service.add_consumer(cj)              
    end 
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



  def inspect_container
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    ret_val = @core_api.inspect_container self
    return ret_val
  end

  def save_state()
    if @core_api == nil
      @last_error="No connection to Engines OS System"      
      return false
    end
    trim_last_result
    trim_last_error
    ret_val = @core_api.save_container self
    return ret_val
  end
  
  def save_blueprint blueprint
    if @core_api == nil
         @last_error="No connection to Engines OS System"      
         return false
       end
       ret_val = @core_api.save_blueprint(blueprint, self)
       return ret_val
  end
  
  def load_blueprint
    if @core_api == nil
            @last_error="No connection to Engines OS System"      
            return false
          end
          ret_val = @core_api.load_blueprint(self)
          return ret_val
  end
  
  def rebuild_container
    if @core_api == nil
          @last_error="No connection to Engines OS System"      
           return false
     end
    ret_val = @core_api.rebuild_image(self)
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
    if @core_api == nil
           @last_error="No connection to Engines OS System"      
            return false
     end
     ret_val = @core_api.is_startup_complete(self)
    return ret_val
end

def has_container?
  if read_state == "nocontainer"
    return false
  else
    return true
  end     
end

  def is_error
    state = read_state
    if setStat != state
      return false
    else
      return true
    end   
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
  
  def enable_https_only
    deregister_site
    @protocol=:https_only
     p :enable_https_only
   register_site
    save_state
  end
  
  def enable_http_only
    p :enable_http_only
    deregister_site
    @protocol=:http_only
    register_site
    save_state
  end
  
 def enable_http_and_https
   p :disable_httpsonly
   deregister_site
   @protocol=:http_and_https
   register_site
   save_state
 end
  
  protected
  
def trim_last_result
  #FIX ME tyhsi breaks teh yaml  if it cuts off trailing "
#  if @last_result.is_a?(String) && @last_result.length >256
#    @last_result=@last_result.slice!(0,256)
#  end
end
def trim_last_error
  #FIX ME tyhsi breaks teh yaml  if it cuts off trailing "
#  if  @last_error.is_a?(String) && @last_error.length >256
#    @last_error=@last_error.slice!(0,256)
#  end
end

  def clear_error ret_val
    if ret_val==true
      @last_error=nil
    end
  end

    def set_container_id
   return "-1"  

    end
    
def log_error_msg(msg,object)
   obj_str = object.to_s.slice(0,256)
   
   @last_error = msg +":" + obj_str
   SystemUtils.log_error_msg(msg,object)

 end
    
end

