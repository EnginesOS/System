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
    @hostname.to_s + "." +@domain_name.to_s
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
  :ctype

  attr_accessor   :container_api,\
  :last_result

  attr_reader :container_id, :conf_self_start

  def docker_info
    return nil if @docker_info.nil?
    info = @docker_info.dup
    return info.freeze
  end

  def engine_environment
    @environments
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

  def self.from_yaml(yaml, container_api)
    managedContainer = YAML.load(yaml)
    return SystemUtils.log_error_mesg(" Failed to Load yaml ", yaml) if managedContainer.nil?
    managedContainer.container_api = container_api
    managedContainer.expire_engine_info
    managedContainer.set_running_user
    managedContainer.lock_values
    return managedContainer
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def to_s
    "#{@container_name.to_s}, #{@ctype}, #{@memory}, #{@hostname}, #{@conf_self_start}, #{@environments}, #{@image}, #{@volumes}, #{@port}, #{@eports}  \n"
  end

  def read_state
    return 'nocontainer' if @setState == 'nocontainer'  # FIXME: this will not support notification of change
    if inspect_container == false
      log_error_mesg('Failed to inspect container', self)
      state = 'nocontainer'
    else
      #        @res= last_result
      output = JSON.parse(@last_result)
      if output.is_a?(Array) == false || output.empty? == true
        log_error_mesg('Failed to get container status', self)
        return 'nocontainer'
      end
      if output[0]['State']
        if output[0]['State']['Running']
          state = 'running'
          if output[0]['State']['Paused']
            state= 'paused'
          end
        elsif output[0]['State']['Running'] == false
          state = 'stopped'
        else
          state = 'nocontainer'
        end
      end
    end
    if state.nil? #Kludge
      state = 'nocontainer'
      @last_error = 'state nil'
    end
    if state != @setState
      @last_error = @last_error.to_s + ' Warning State Mismatch set to ' + @setState + ' but in ' + state + ' state'
    end
    return state
  rescue Exception=>e
    p :json_Str
    p @last_result
    SystemUtils.log_exception(e)
    return 'nocontainer'
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
    state = read_state()
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
    state = read_state
    @setState = 'nocontainer' # this represents the state we want and not necessarily the one we get
    if is_active? == false
      ret_val = @container_api.destroy_container(self)
      @container_id = '-1'
      expire_engine_info
    else
      log_error_mesg('Cannot Destroy a container that is not stopped\nPlease stop first', state)
    end
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
    if state == 'nocontainer'
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
    state = read_state
    @setState = 'running'
    if state == 'nocontainer'
      ret_val = @container_api.create_container(self)
    else
      log_error_mesg('Cannot create container as container exists ', state)
    end
    expire_engine_info
    if read_state != 'running'
      @container_id = -1
      return log_err_mesg('Did not start',self)
    else
      set_container_id
      register_with_dns # MUst register each time as IP Changes
      add_nginx_service if @deployment_type == 'web'
      @container_api.register_non_persistant_services(self)
    end
    @container_id = set_container_id
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
    state = read_state
    @setState = 'running'
    ret_val = false
    if state == 'paused'
      ret_val = @container_api.unpause_container(self)
      expire_engine_info
    else
      log_error_mesg('Can\'t Start upayse as ', state)
    end
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
    clear_error
    save_state
  end

  def pause_container
    return false unless has_api?
    state = read_state
    @setState = 'paused'
    ret_val = false
    if state == 'running'
      ret_val = @container_api.pause_container(self)
      expire_engine_info
    else
      log_error_mesg('Can\'t Pause Container as ', state)
    end
    @container_api.deregister_non_persistant_services(self)
    clear_error
    save_state
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

  # @return a containers ip address as a [String]
  # @return nil if exception
  # @ return false on inspect container error
  def get_ip_str
    expire_engine_info
    return false if inspect_container == false
    output = JSON.parse(@last_result)
    ip_str = output[0]['NetworkSettings']['IPAddress']
    return ip_str
  rescue
    return nil
rescue StandardError => e
  log_exception(e)
  end

  def set_deployment_type(deployment_type)
    @deployment_type = deployment_type
    return remove_nginx_service if @deployment_type && @deployment_type != 'web'
    add_nginx_service if @deployment_type == 'web'
  end

  def stats
    expire_engine_info
    return false if inspect_container == false
    output = JSON.parse(@last_result)
    return false if !output.is_a?(Array)
    return false if !output[0].is_a?(Hash)
    started = output[0]['State']['StartedAt']
    stopped = output[0]['State']['FinishedAt']
    state = read_state
    ps_container
    pcnt = -1
    rss = 0
    vss = 0
    h = m = s = 0
    @last_result.each_line.each do |line|
      if pcnt > 0 # skip the fist line with is a header
        fields = line.split  #  [6]rss [10] time
        if fields.nil? == false
          rss += fields[7].to_i
          vss += fields[6].to_i
          time_f = fields[11]
          c_HMS = time_f.split(':')
          if c_HMS.length == 3
            h += c_HMS[0].to_i
            m += c_HMS[1].to_i
            s += c_HMS[2].to_i
          else
            m += c_HMS[0].to_i
            s += c_HMS[1].to_i
          end
        end
      end
      pcnt += 1
    end
    cpu = 3600 * h + 60 * m + s
    statistics = ContainerStatistics.new(state, pcnt, started, stopped, rss, vss, cpu)
    statistics
  end

  def running_user
    return -1 if inspect_container == false
    output = JSON.parse(@last_result)
    return -1 if output.nil?
    return  output[0]['Config']['User'] if output.is_a?(Array) && output[0].is_a?(Hash)
  rescue StandardError => e
    return log_exception(e)
  end

  def set_running_user
    @cont_userid = running_user if @cont_userid.nil? || @cont_userid == -1
  end

  def inspect_container
    return false unless has_api?  
    result = @container_api.inspect_container(self) if @docker_info.nil?
    return nil if result == false
    @docker_info = @last_result
    Thread.new { sleep 3 ; expire_engine_info }
    return result
  end

  def save_state()
    return false unless has_api?
    expire_engine_info
#    p :saveStat
#    p caller[0][/`([^']*)'/, 1]
    @container_api.save_container(self)
  end

  def save_blueprint blueprint
    return false unless has_api?
    @container_api.save_blueprint(blueprint, self)
  end

  def load_blueprint
    return false unless has_api?
    @container_api.load_blueprint(self)
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

  def is_running?
    expire_engine_info
    state = read_state
    return true if state == 'running'
    return false
  end

  def is_startup_complete?
    return false unless has_api?
    @container_api.is_startup_complete(self)
  end

  def has_container?
    return false if has_image? == false
    return false if read_state == 'nocontainer'
    return true
  end

  def has_image?
    @container_api.image_exist?(@image)
  end

  def is_error?
    state = read_state
    return true if @setState != state
    return false
  end

  def is_active?
    state = read_state
    case state
    when 'running'
      return true
    when 'paused'
      return true
    else
      return false
    end
  end

  def expire_engine_info
    @docker_info = nil
  end

  def get_container_memory_stats()
    @container_api.get_container_memory_stats(self)
  end

  def get_container_network_metrics()
    @container_api.get_container_network_metrics(self)
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

  def has_api?
    return log_error_mesg('No connection to Engines OS System',nil) if @container_api.nil?
    return true
  end

  def set_container_id
    inspect_container if @docker_info.nil?
    return @docker_info[0]['Id'] if @docker_info.is_a?(Array) && @docker_info[0].is_a?(Hash)
    return -1
  end
end
