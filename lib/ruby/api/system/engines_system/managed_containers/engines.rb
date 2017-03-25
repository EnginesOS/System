

module Engines
  def list_managed_engines
    clear_error
    ret_val = []
    begin
      Dir.entries(SystemConfig.RunDir + '/containers/').each do |contdir|
        yfn = SystemConfig.RunDir + '/containers/' + contdir + '/running.yaml'
        ret_val.push(contdir) if File.exist?(yfn)
      end
    rescue
    end
    ret_val
  end

  def init_engine_dirs(engine_name)
    c = FakeContainer.new(engine_name)
    STDERR.puts(' creating ' + container_state_dir(c).to_s + '/run')
    FileUtils.mkdir_p(container_state_dir(c) + '/run') unless Dir.exist?(container_state_dir(c)+ '/run')
    FileUtils.mkdir_p(container_state_dir(c) + '/run/flags') unless Dir.exist?(container_state_dir(c)+ '/run/flags')
    FileUtils.mkdir_p(container_log_dir(c)) unless Dir.exist?(container_log_dir(c))
    FileUtils.mkdir_p(container_ssh_keydir(c)) unless Dir.exist?(container_ssh_keydir(c))
  end

  def set_engine_network_properties(engine, params)
    clear_error
    set_engine_hostname_details(engine, params) if set_engine_web_protocol_properties(engine, params)
  end

  def set_engine_web_protocol_properties(engine, params)
    clear_error

    protocol = params[:http_protocol]
    raise EnginesException.new(error_hash('no protocol field')) if protocol.nil?
    protocol.downcase
    protocol.gsub!(/ /,"_")
    SystemDebug.debug(SystemDebug.services,'Changing protocol to _', protocol)
    if protocol.include?('https_only')
      engine.enable_https_only
    elsif protocol.include?('http_only')
      engine.enable_http_only
    elsif protocol.include?('https_and_http')
      engine.enable_http_and_https
    end
    true
  end

  def set_engine_hostname_details(container, params)
    clear_error
    #    p :set_engine_network_properties
    #    p container.container_name
    #    p params
    #FIXME [:hostname]  silly host_name from gui drop it
    if params.key?(:host_name)
      hostname = params[:host_name]
    else
      hostname = params[:hostname]
    end

    domain_name = params[:domain_name]
    SystemDebug.debug(SystemDebug.services,'Changing Domainame to ', domain_name)

    container.remove_nginx_service
    container.set_hostname_details(hostname, domain_name)
    container.save_state
    # save_container(container)
    container.add_nginx_service
    true
  end

  def getManagedEngines
    ret_val = []
    Dir.entries(SystemConfig.RunDir + '/containers/').each do |contdir|
      yfn = SystemConfig.RunDir + '/containers/' + contdir + '/running.yaml'
      if File.exist?(yfn)
        begin
          managed_engine = loadManagedEngine(contdir)
          ret_val.push(managed_engine)
        rescue
        end
      end
    end
    ret_val
  end

  def loadManagedEngine(engine_name)
    raise EnginesException.new(error_hash('Nil Engine Name', engine_name)) if engine_name.nil?
    e = engine_from_cache(engine_name)
    return e if e.is_a?(ManagedEngine)
    raise EnginesException.new(error_hash('No Engine name', engine_name)) if engine_name.nil? || engine_name.length == 0
    yaml_file_name = SystemConfig.RunDir + '/containers/' + engine_name + '/running.yaml'
    raise EnginesException.new(error_hash('No Engine file', engine_name)) unless File.exist?(yaml_file_name)
    raise EnginesException.new(error_hash('Engine File Locked',yaml_file_name)) if is_container_conf_file_locked?(SystemConfig.RunDir + '/containers/' + engine_name)
    yaml_file = File.read(yaml_file_name)
    ts = File.mtime(yaml_file_name)
    managed_engine = ManagedEngine.from_yaml(yaml_file, @engines_api.container_api)
    cache_engine(managed_engine, ts)
    managed_engine
  end

#  def delete_engine(container)
#    rm_engine_from_cache(container.container_name)
#  end

end