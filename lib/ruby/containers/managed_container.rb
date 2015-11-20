require_relative 'container_statistics.rb'
require_relative 'ManagedContainerObjects.rb'
require_relative 'container.rb'

require 'objspace'

class ManagedContainer < Container
  @conf_self_start = false
  @restart_required = false
  @rebuild_required = false
  attr_accessor :task_at_hand, :restart_required, :rebuild_required
  def desired_state(state)
    @setState = state
    save_state
  end

  def restart_required?
    return false unless has_api?
    @container_api.restart_required?(self)
  end

  def restart_reason
    return false unless has_api?
    @container_api.restart_reason(self)
  end

  def rebuild_required?
    return false unless has_api?
    @container_api.rebuild_required?(self)
  end

  def rebuild_reason
    return false unless has_api?
    @container_api.rebuild_reason(self)
  end

  def in_progress(state)
    @task_at_hand = state
    current_state = @setState
    case state
    when :create
      desired_state('running')
    when :stop
      desired_state('stopped')
    when :start
      desired_state('running')
    when :pause
      desired_state('paused')
    when :restart
      desired_state('running')
    when :unpause
      desired_state('running')
    when :recreate
      desired_state('running')
    when :rebuild
      desired_state('running')
    when :build
      desired_state('running')
    when :delete
      desired_state('nocontainer')
      #  desired_state('noimage')
    when :destroy
      desired_state('nocontainer')
    end
    STDERR.puts 'Task at Hand:' + state.to_s + ' Current state' + current_state.to_s + ' going for ' + @task_at_hand.to_s
  end

  def log_error_mesg(msg, e_object)
    task_failed(msg)
    super
  end

  def post_load
    @last_task =  @task_at_hand = nil
    super
  end

  def task_failed(msg)
    p :task_failed
    p @task_at_hand
    p msg.to_s
    task_complete
    return false
  end

  def task_complete
    @last_task =  @task_at_hand
    @task_at_hand = nil
    save_state
    return true
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
  :deployment_type,\
  :dependant_on,\
  :no_ca_map,\
  :hostname,\
  :domain_name,\
  :ctype,
  :conf_self_start

  def read_state
    #return 'nocontainer' if @setState == 'nocontainer'  # FIXME: this will not support notification of change
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
      @last_error = @last_error.to_s + ' Warning State Mismatch set to ' + @setState.to_s + ' but in ' + state.to_s + ' state'
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
    if @protocol == :http_https
      return 'http'
    end
    return @protocol.to_s
  end

  def set_protocol(proto)
    case proto
    when 'HTTP and HTTPS'
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
    "#{@container_name.to_s}, #{@ctype}, #{@memory}, #{@hostname}, #{@conf_self_start}, #{@environments}, #{@image}, #{@volumes}, #{@web_port}, #{@mapped_ports}  \n"
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
    in_progress(:delete)
    r =  super
    @last_task =  @task_at_hand
    @task_at_hand = nil
    return r
  end

  def destroy_container
    return false unless has_api?
    clear_error
    in_progress(:destroy) # this represents the state we want and not necessarily the one we get
    return task_complete if super
    task_failed('destroy')
  end

  def setup_container
    clear_error
    return false unless has_api?
    ret_val = false
    state = read_state
    in_progress(:stop)
    unless has_container?
      ret_val = @container_api.setup_container(self)
      expire_engine_info
    else
      task_failed('setup')
      log_error_mesg('Cannot create container as container exists ',state)
    end
    return task_complete if ret_val
    task_failed('setup')
  end

  def create_container
    clear_error
    return false unless has_api?
    in_progress(:create)
    return false unless super
    state = read_state
    return log_error_mesg('No longer running ' + state + ':' + @setState, self) unless state == 'running'
    register_with_dns # MUst register each time as IP Changes
    add_nginx_service if @deployment_type == 'web'
    @container_api.register_non_persistant_services(self)
    task_complete
  rescue StandardError => e
    log_exception(e)
  end

  def recreate_container
    ret_val = false
    in_progress(:recreate)
    destroy_container
    create_container
  end

  def unpause_container
    clear_error
    return false unless has_api?
    in_progress(:unpause)
    ret_val = false
    return task_failed('unpause') unless super
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
    task_complete
  end

  def pause_container
    clear_error
    return false unless has_api?
    in_progress(:pause)
    return task_failed('pause') unless super
    @container_api.deregister_non_persistant_services(self)
    task_complete
  end

  def stop_container
    clear_error
    return false unless has_api?
    in_progress(:stop)
    @container_api.deregister_non_persistant_services(self)
    return task_failed('stop') unless super
    task_complete
  end

  def start_container
    clear_error
    return false unless has_api?
    in_progress(:start)
    return task_failed('start') unless super
    @restart_required = false
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
    task_complete
  end

  # Register the dns
  # bootsrap service dns into ManagedService registry
  # would be better if it check a pre exisiting record will throw error on recreate
  #
  def register_with_dns # MUst register each time as IP Changes
    return false unless has_api?
    return true unless @conf_register_dns
    @container_api.register_with_dns(self)

  end

  def restart_container

    in_progress(:restart)
    return task_failed('restart/stop') unless stop_container
    return task_failed('restart/start') unless start_container
    task_complete
  end

  def set_deployment_type(deployment_type)
    @deployment_type = deployment_type
    return remove_nginx_service if @deployment_type && @deployment_type != 'web'
    add_nginx_service if @deployment_type == 'web'
  end

  def save_state()
    return false unless has_api?
    info = @docker_info_cache
    @docker_info_cache = false
    @container_api.save_container(self)
    @docker_info_cache = info
  end

  def save_blueprint blueprint
    return false unless has_api?
    @container_api.save_blueprint(blueprint, self)
  end

  def rebuild_container
    return false unless has_api?
    in_progress(:rebuild)
    ret_val = @container_api.rebuild_image(self)
    expire_engine_info
    if ret_val == true
      register_with_dns # MUst register each time as IP Changes
      #add_nginx_service if @deployment_type == 'web'
      @container_api.register_non_persistant_services(self)
    end
    return task_complete if ret_val
    task_failed('rebuild')
  end

  def is_startup_complete?
    return false unless has_api?
    @container_api.is_startup_complete(self)
  end

  def is_error?
    return false unless @task_at_hand.nil?
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

  def add_volume(service_hash)
    permissions = PermissionRights.new(service_hash[:parent_engine] , '', '')
    vol = Volume.new(service_hash) #service_hash[:variables][:name], SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine]  + '/' + service_hash[:variables][:name], service_hash[:variables][:engine_path], 'rw', permissions)
    @volumes[service_hash[:variables][:name]] = vol
    save_state
  rescue StandardError => e
    p :add_volume
    p service_hash
    log_exception(e)
  end

  protected

  # create nginx service_hash for container and register with nginx
  # @return boolean indicating sucess
  def add_nginx_service
    return false unless has_api?
    @container_api.add_nginx_service(self)
  end

  # create nginx service_hash for container deregister with nginx
  # @return boolean indicating sucess
  def remove_nginx_service
    return false unless has_api?
    @container_api.remove_nginx_service(self)
  end
end
