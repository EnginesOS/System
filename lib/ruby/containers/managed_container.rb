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
    @web_port = port
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
  
  def desired_state=(state)
    @setState = state
    save_state
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
   @protocol
   
  end

  def set_protocol(proto)
    case proto
    when 'HTTPS and HTTP'
      enable_http_and_https
    when 'HTTP only'
      enable_http_only
    when 'HTTPS only'
      enable_https_only
    else
      @protocol = proto.to_sym
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
    "#{@container_name.to_s}, #{@ctype}, #{@memory}, #{@hostname}, #{@conf_self_start}, #{@environments}, #{@image}, #{@volumes}, #{@web_port}, #{@eports}  \n"
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

  def delete_image()
    return false unless has_api?
    ret_val = false
    clear_error
    desired_state=('noimage')
    super
  end

  def destroy_container
    return false unless has_api?
    clear_error
    desired_state=('nocontainer') # this represents the state we want and not necessarily the one we get
    super 
  end

  def setup_container
    clear_error
    return false unless has_api?
    ret_val = false
    state = read_state
    desired_state=('stopped')
    unless has_container?
      ret_val = @container_api.setup_container(self)
      expire_engine_info
    else
      log_error_mesg('Cannot create container as container exists ',state)
    end
  end

  def create_container
    clear_error
    return false unless has_api?
    desired_state=('running')
    return false unless super
    sleep 10
    return log_error_mesg('Did not start',self) unless is_running?
    register_with_dns # MUst register each time as IP Changes
    add_nginx_service if @deployment_type == 'web'
    @container_api.register_non_persistant_services(self)
  rescue StandardError => e
    log_exception(e)
  end

  def recreate_container
    ret_val = false
    desired_state=('running')
    destroy_container
    create_container
  end

  def unpause_container
    clear_error
    return false unless has_api?
    desired_state=('running')
    ret_val = false
   return false unless super
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
  end

  def pause_container
    clear_error
    return false unless has_api?
    desired_state=('paused')
    return false unless super
    @container_api.deregister_non_persistant_services(self)  
  end

  def stop_container
    clear_error
    return false unless has_api?
    #    web_sites
    ret_val = false
    desired_state=('stopped')      
    @container_api.deregister_non_persistant_services(self)
    return false unless super
  end

  def start_container
    clear_error
    return false unless has_api?
    ret_val = false
    desired_state=('running')
    return false unless super
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
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




  
  def save_state()
    return false unless has_api?    
    info = @docker_info
    expire_engine_info
    @container_api.save_container(self)
    @docker_info = info
    
  end

  def save_blueprint blueprint
    return false unless has_api?
    @container_api.save_blueprint(blueprint, self)
  end

  def rebuild_container
    return false unless has_api?
    desired_state=('running')
    ret_val = @container_api.rebuild_image(self)
    expire_engine_info
    if ret_val == true
      register_with_dns # MUst register each time as IP Changes
      #add_nginx_service if @deployment_type == 'web'
      @container_api.register_non_persistant_services(self)
    end    
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



  

end
