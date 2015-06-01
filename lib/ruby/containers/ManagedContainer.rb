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
    @container_name = name
    @hostname = host
    @domain_name = domain
    @image = image
    @eports = e_ports
    @volumes = vols
    @environments = environs
    @conf_self_start=false
    @last_error=""
    @last_result=""
    @data_uid=data_uid
    @data_gid=data_gid
    @cont_userid=-1
    @protocol=:http_and_https
  end

  def container_id

      @container_id = set_container_id
      if @container_id == false || @container_id == nil
        @container_id == "-1"
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
  :volumes,\
  :deployment_type

  attr_accessor :container_id,\
  :core_api,\
  :conf_self_start,\
  :last_result,\
  :last_error,
  :docker_info

  def is_service?
    if @ctype && @ctype != nil && @ctype == "service"
      return true
    end

    return false
  end

  def engine_name
    @container_name
  end

  def engine_environment
    return @environments
  end

  #to support Gui's wierd convention on names
  def containerName
    return @container_names
  end

  def domainName
    return @domain_name
  end

  def hostName
    return @hostname
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

  def ManagedContainer.from_yaml( yaml, core_api )
    managedContainer = YAML::load( yaml )
    managedContainer.core_api = core_api
    managedContainer.docker_info = nil
    managedContainer
  end

  def to_s
    "#{@container_name.to_s}, #{@ctype}, #{@memory}, #{@hostname}, #{@self_start}, #{@environments}, #{@image}, #{@volumes}, #{@port}, #{@eports}  \n"
  end

  def read_state()

    #    p :read_state
    # p   caller_locations(1,1)[0].label

    begin
      if inspect_container == false
        state="nocontainer"
      else
        @res= last_result
        output = JSON.parse(last_result)
        if output.is_a?(Array) == false || output.empty? == true
          @last_error = "Failed to get container status"
          return "nocontainer"
        end
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
        @last_error = "state nil"
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
    return false  if has_api? == false

    return @core_api.logs_container(self)
  end

  def ps_container
    return false  if has_api? == false

    return @core_api.ps_container(self)

  end

  def delete_image()
    return false  if has_api? == false

    ret_val=false
    state = read_state()
    if  has_container? == false
      ret_val = @core_api.delete_image(self)
    else
      @last_error ="Cannot Delete the Image while container exists. Please stop/destroy first"
    end
    clear_error(ret_val)
    return ret_val
  end

  def destroy_container
    return false  if has_api? == false

    ret_val=false

    state = read_state
    @setState="nocontainer" #this represents the state we want and not necessarily the one we get
    p :set_state_in_destroy
    @container_id="-1"
    p @setState
    if is_active? == false      
        ret_val = @core_api.destroy_container self
      @docker_info = nil
    else 
        @last_error ="Cannot Destroy a container that is not stopped\nPlease stop first"
    end

      clear_error(ret_val)

      @setState="nocontainer"#this represents the state we want and not necessarily the one we get
      save_state()
      p @setState
      return ret_val
    
  end

  def setup_container
    return false  if has_api? == false

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
    return false  if has_api? == false

    ret_val =false
    state = read_state()

    if state == "nocontainer"
      ret_val = @core_api.create_container self
      @setState="running"
    else
      @last_error ="Cannot create container if container by the same name exists"
    end
    @docker_info = nil
    if read_state != "running"
      @last_error ="Did not start"
      ret_val = false
    else
      register_with_dns
      if @deployment_type  == "web"
        add_nginx_service
      end
      @core_api.register_non_persistant_services(self)
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
    return false  if has_api? == false

    state = read_state()

    ret_val = false
    if state == "paused"
      @setState="running"
      ret_val= @core_api.unpause_container self
      @docker_info = nil
    else
      @last_error ="Can't unpause Container as " + state
    end
    @core_api.register_non_persistant_services(self)
    clear_error(ret_val)
    save_state()
    return ret_val

  end

  def pause_container
    return false  if has_api? == false

    state = read_state()

    ret_val = false
    if state == "running"
      @setState="paused"
      ret_val = @core_api.pause_container self
      @docker_info = nil
    else
      @last_error ="Can't pause Container as " + state
    end
    @core_api.deregister_non_persistant_services(self)
    clear_error(ret_val)
    save_state()
    return ret_val
  end

  def stop_container
    return false  if has_api? == false

    ret_val = false
    state = read_state()

    if state== "running"
      ret_val = @core_api.stop_container   self
      @core_api.deregister_non_persistant_services(self)
      @docker_info = nil
      @setState="stopped"
    else
      @last_error ="Can't stop Container as " + state
      if state != "paused" #force deregister if stopped or no container etc
        @core_api.deregister_non_persistant_services(self)
      end
    end

    clear_error(ret_val)
    save_state()
    return  ret_val
  end

  def start_container
    return false  if has_api? == false

    ret_val=false
    state = read_state()

    if state == "stopped"
      ret_val = @core_api.start_container self
      @setState="running"
      @docker_info = nil
    else
      @last_error ="Can't Start Container as " + state
    end
    register_with_dns
    @core_api.register_non_persistant_services(self)

    clear_error(ret_val)
    save_state()
    return ret_val
  end

  #Register the dns
  #bootsrap service dns into ManagedService registry
  #would be better if it check a pre exisiting record will throw error on recreate
  #
  def register_with_dns
    return false  if has_api? == false

    service_hash = SystemUtils.create_dns_service_hash(self)
    if service_hash == nil
      return false
    end

    return  @core_api.attach_service(service_hash)
  end

  def restart_container
    ret_val=false
    if (ret_val = stop_container  ) == true
      ret_val = start_container
    end
    return ret_val
  end

  #@return a containers ip address as a [String]
  #@return nil if exception
  #@ return false on inspect container error
  def get_ip_str
    @docker_info = nil
    p :read_ip
    if inspect_container == false
      return false
    end
    output = JSON.parse(@last_result)
    ip_str=output[0]['NetworkSettings']['IPAddress']
    #    puts container_name + ":" + ip_str
    return ip_str
  rescue
    return nil
  end

  def set_deployment_type(deployment_type)
    #remove existing service mapping
    if @deployment_type && @deployment_type == "web"
      return remove_nginx_service
    end
    @deployment_type = deployment_type
    if @deployment_type == "web"
      return add_nginx_service
    end
  end

  #create nginx service_hash for container and register with nginx
  #@return boolean indicating sucess
  def add_nginx_service
    return false  if has_api? == false

    service_hash =  SystemUtils.create_nginx_service_hash(self)
    return @core_api.attach_service(service_hash)
  end

  #create nginx service_hash for container deregister with nginx
  #@return boolean indicating sucess
  def remove_nginx_service
    return false  if has_api? == false

    service_hash =  SystemUtils.create_nginx_service_hash(self)
    return @core_api.dettach_service(service_hash)
  end

  def stats

    if inspect_container() == false
      return false
    end
    p :read_stats
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
    return false  if has_api? == false

    if @docker_info == nil
      @docker_info = @core_api.inspect_container self
    end
    return @docker_info
  end

  def save_state()
    return false  if has_api? == false

    @docker_info = nil
    ret_val = @core_api.save_container self
    return ret_val
  end

  def save_blueprint blueprint
    return false  if has_api? == false

    ret_val = @core_api.save_blueprint(blueprint, self)
    return ret_val
  end

  def load_blueprint
    return false  if has_api? == false

    ret_val = @core_api.load_blueprint(self)
    return ret_val
  end

  def rebuild_container
    return false  if has_api? == false

    ret_val = @core_api.rebuild_image(self)
    if ret_val == true
      register_with_dns
      if @deployment_type  == "web"
        add_nginx_service
      end
      @core_api.register_non_persistant_services(self)
      save_state()
    end
    return ret_val
  end

  def is_running?
    state = read_state
    if state == "running"
      return true
    end

    return false

  end

  def is_startup_complete?
    return false  if has_api? == false

    ret_val = @core_api.is_startup_complete(self)
    return ret_val
  end

  def has_container?
    if read_state == "nocontainer"
      return false
    end
    return true
  end

  def is_error?
    state = read_state
    if @setState != state
      return false
    end
    return true
  end
  
  def is_active
    return is_active?
  end

  def is_active?
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
#
#  def enable_https_only
#    @protocol=:https_only
#    p :enable_https_only
#    save_state
#  end
#
#  def enable_http_only
#    p :enable_http_only
#    @protocol=:http_only
#    save_state
#  end
#
#  def enable_http_and_https
#    p :disable_httpsonly
#    deregister_site
#    @protocol=:http_and_https
#    register_site
#    save_state
#  end

  protected

  def has_api?
    if @core_api == nil
      @last_error="No connection to Engines OS System"
      return false
    end
    return true
  end

  def clear_error ret_val
    if ret_val==true
      @last_error=nil
    end
  end

  def set_container_id
    if @docker_info == nil || @docker_info == false  || @docker_info.is_a?(Array) == false ||  @docker_info.empty? == true
      return "-1"
    end

    return @docker_info[0]["Id"]

  end

  def log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,256)

    @last_error = msg +":" + obj_str
    SystemUtils.log_error_mesg(msg,object)

  end

end