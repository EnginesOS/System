require_relative 'container_statistics.rb'
require_relative 'ManagedContainerObjects.rb'
require_relative 'container.rb'

require 'objspace'
class ManagedContainer < Container
  @conf_self_start = false
  #  @http_and_https=true
  #  @https_only=false
  def initialize(mem, name, host, domain, image, e_ports, vols, environs, framework, runtime, databases, setState, port, repo, data_uid, data_gid) # used for test only
    @framework = framework
    @runtime = runtime
    @databases = databases
    @setState = setState
    @port = port
    @repository = repo
    @last_error = last_error
    @memory = mem
    @container_name = name
    @hostname = host
    @domain_name = domain
    @image = image
    @eports = e_ports
    @volumes = vols
    @environments = environs
    @conf_self_start = false
    @last_error = ''
    @last_result = ''
    @data_uid = data_uid
    @data_gid = data_gid
    @cont_userid = -1
    @protocol = :http_and_https
    @docker_info = false
  end

  attr_accessor :current_operation

  def current_operation=(operation)
    @current_operation = operation
    #     save_operation
    #     lock_state
  end

  def operation_completed
    @current_operation = nil
    #     unlock_state
  end

  def fqdn
     @hostname + '.' + @domain_name
   end

  def repo
    @repository
  end

  def web_sites
    @container_api.web_sites_for(self)
  end

  # @returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image
    return true
  end

  attr_reader :framework,\
  :runtime,\
  :databases,\
  :port,\
  :repository,\
  :data_uid,\
  :data_gid,\
  :cont_userid,\
  :setState,\
  :protocol,\
  :volumes,\
  :deployment_type,\
  :dependant_on,\
  :no_ca_map,\
  :hostname,\
  :domain_name,\
  :ctype,
  :conf_self_start
  
  def read_state
      return 'nocontainer' if @setState == 'nocontainer'  # FIXME: this will not support notification of change
      if docker_info.is_a?(FalseClass)
        log_error_mesg('Failed to inspect container', self)
        state = 'nocontainer'
      else
        state = super             
      if state.nil? #Kludge
        state = 'nocontainer'
        @last_error = 'state nil'
      end
      end
      if state != @setState
        @last_error = @last_error.to_s + ' Warning State Mismatch set to ' + @setState + ' but in ' + state + ' state'
      end
      return state
    rescue Exception=>e
      p @last_result
      log_exception(e)
      return 'nocontainer'
    end
    

  def is_service?
    return true if @ctype == 'service'
    return false
  end

  def engine_name
    @container_name
  end

  def engine_environment
    return @environments
  end

  def http_protocol
    case @protocol
    when :http_and_https
      return 'HTTPS and HTTP'
    when :http_only
      return 'HTTP only'
    when :https_only
      return 'HTTPS only'
    end
    p 'no web protocol err'
    return 'HTTP only'
  end

  def set_protocol(proto)
    case proto
    when 'HTTPS and HTTP'
      enable_http_and_https
    when 'HTTP only'
      enable_http_only
    when 'HTTPS only'
      enable_https_only
    end
  end

  def enable_http_and_https
    @protocol = :http_and_https
  end

  def enable_https_only
    @protocol = :https_only
  end

  def enable_http_only
    @protocol = :http_only
  end



  def to_s
    "#{@container_name.to_s}, #{@ctype}, #{@memory}, #{@hostname}, #{@conf_self_start}, #{@environments}, #{@image}, #{@volumes}, #{@port}, #{@eports}  \n"
  end

  def fqdn
    return 'N/A' if @domain_name.nil? == true
    return @hostname.to_s + '.' + @domain_name.to_s
  end
   
   def set_hostname_details(host_name, domain_name)
     @hostname = host_name
     @domain_name = domain_name
     return true
   end

  def logs_container
    return false unless has_api?
    @container_api.logs_container(self)
  end

  def ps_container
    expire_engine_info
    return false unless has_api?
    @container_api.ps_container(self)
  end

  def delete_image()
    return false unless has_api?
    ret_val = false
    if has_container? == false
      ret_val = @container_api.delete_image(self)
    else
      @last_error ='Cannot Delete the Image while container exists. Please stop/destroy first'
    end
    clear_error
    return ret_val
  end

  def destroy_container
    return false unless has_api?
    clear_error
    ret_val = false
    return  log_error_mesg('Cannot Destroy a container that is not stopped\nPlease stop first', state) if is_active?
    @setState = 'nocontainer' # this represents the state we want and not necessarily the one we get
    ret_val = @container_api.destroy_container(self)
    @container_id = '-1'
    expire_engine_info
    @setState = 'nocontainer' # this represents the state we want and not necessarily the one we get
    save_state()
    return ret_val
  end

  def setup_container
    clear_error
    return false unless has_api?
    ret_val = false
    state = read_state
    @setState = 'stopped'
    unless has_container?
      ret_val = @container_api.setup_container(self)
      expire_engine_info
    else
      log_error_mesg('Cannot create container as container exists ',state)
    end
    save_state
  end

  def create_container
    clear_error
    return false unless has_api?
    ret_val = false
    expire_engine_info
    @setState = 'running'
    return log_error_mesg('Cannot create container as container exists ', self) if has_container?
      ret_val = @container_api.create_container(self)
    expire_engine_info
    return log_error_mesg('Did not start',self) unless is_running?
    register_with_dns # MUst register each time as IP Changes
    add_nginx_service if @deployment_type == 'web'
    @container_api.register_non_persistant_services(self)
    @container_id = read_container_id
    @cont_userid = running_user
    save_state
    return ret_val
  rescue StandardError => e
    log_exception(e)
  end

  def recreate_container
    ret_val = false
    destroy_container
    ret_val = create_container
    @setState = 'running'
    save_state
    return ret_val
  end

  def unpause_container
    return false unless has_api?
    @setState = 'running'
    ret_val = false
    return log_error_mesg('Can\'t Start unpause as no paused', self) unless is_paused?
    ret_val = @container_api.unpause_container(self)
    expire_engine_info
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
    clear_error
    save_state
  end

  def pause_container
    return false unless has_api?
    @setState = 'paused'
    ret_val = false
    return log_error_mesg('Can\'t Pause Container as not running', self) unless is_running?
    ret_val = @container_api.pause_container(self)
    expire_engine_info
    @container_api.deregister_non_persistant_services(self)
    clear_error
    save_state
    return true
  end

  def stop_container
    return false unless has_api?
    #    web_sites
    ret_val = false
    state = read_state
    @setState = 'stopped'
    if state == 'running'
      ret_val = @container_api.stop_container(self)
      @container_api.deregister_non_persistant_services(self)
      expire_engine_info
    else
      log_error_mesg('Can\'t Stop Container as ', state)
      @container_api.deregister_non_persistant_services(self)
    end
    clear_error
    save_state
  end

  def start_container
    return false unless has_api?
    ret_val = false
    state = read_state
    @setState = 'running'
    if state == 'stopped'
      ret_val = @container_api.start_container(self)
      expire_engine_info
    else
      log_error_mesg('Can\'t Start Container as ', state)
    end
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
    clear_error
    save_state
  end

  # Register the dns
  # bootsrap service dns into ManagedService registry
  # would be better if it check a pre exisiting record will throw error on recreate
  #
  def register_with_dns # MUst register each time as IP Changes
    return false unless has_api?
    service_hash = SystemUtils.create_dns_service_hash(self)
    return false if service_hash.is_a?(Hash) == false
    return @container_api.attach_service(service_hash)
  end

  def restart_container
    ret_val = start_container if stop_container
  end



  def set_deployment_type(deployment_type)
    @deployment_type = deployment_type
    return remove_nginx_service if @deployment_type && @deployment_type != 'web'
    add_nginx_service if @deployment_type == 'web'
  end

  
  def running_user
    return -1 if docker_info.is_a?(FalseClass)
    return  docker_info[0]['Config']['User'] unless docker_info.is_a?(FalseClass)
  rescue StandardError => e
    return log_exception(e)
  end

  def set_running_user
    @cont_userid = running_user if @cont_userid.nil? || @cont_userid == -1
  end

  
  def save_state()
    return false unless has_api?
    expire_engine_info
    @container_api.save_container(self)
  end

  def save_blueprint blueprint
    return false unless has_api?
    @container_api.save_blueprint(blueprint, self)
  end

  def rebuild_container
    return false unless has_api?
    ret_val = @container_api.rebuild_image(self)
    expire_engine_info
    if ret_val == true
      register_with_dns # MUst register each time as IP Changes
      #add_nginx_service if @deployment_type == 'web'
      @container_api.register_non_persistant_services(self)
    end
    @setState = 'running'
    save_state
  end

  def is_startup_complete?
    return false unless has_api?
    @container_api.is_startup_complete(self)
  end

  def is_error?
    state = read_state
    return true if @setState != state
    return false
  end

  def lock_values
    @conf_self_start.freeze
    @container_name.freeze
    @data_uid.freeze
    @data_gid.freeze
    @image.freeze
    @repository = '' if @repository.nil?
    @repository.freeze
  rescue StandardError => e
    log_exception(e)
  end

  protected

  # create nginx service_hash for container and register with nginx
  # @return boolean indicating sucess
  def add_nginx_service
    return false unless has_api?
    service_hash = SystemUtils.create_nginx_service_hash(self)
    return @container_api.attach_service(service_hash)
  end

  # create nginx service_hash for container deregister with nginx
  # @return boolean indicating sucess
  def remove_nginx_service
    return false unless has_api?
    service_hash = SystemUtils.create_nginx_service_hash(self)
    @container_api.dettach_service(service_hash)
  end


  def read_container_id
    return docker_info[0]['Id'] unless docker_info.is_a?(FalseClass) # Array) && docker_info[0].is_a?(Hash)    
      return -1
rescue StandardError => e
   log_exception(e)
  end
  

end
