module Services
  def getManagedServices
    get_services_by_type(service)
  end

  def getSystemServices
    get_services_by_type(system_service)
  end

  def list_managed_services
    _list_services
  end

  def list_system_services
    _list_services('system_service')
  end

  def loadSystemService(service_name)
    _loadManagedService(service_name,  '/system_services/')
  end

  def loadManagedService(service_name)
    s = engine_from_cache('services/' + service_name)
    return s if s.is_a?(ManagedService)
    if service_name == 'system'
      s = loadSystemService(service_name)
    else
      s = _loadManagedService(service_name,  '/services/')
      ts = File.mtime(SystemConfig.RunDir + '/services/' + service_name + '/running.yaml')
      cache_engine(s, ts)
    end
    s
  end

  private

  def get_services_by_type(type='service')
    services = _list_services(type)
    ret_val = []
    services.each do |service_name |
      begin
        service = loadManagedService(service_name) if type == 'service'
        service = loadSystemService(service_name) if type == 'system_service'
        ret_val.push(service) if service.is_a?(ManagedService)
      rescue # skip bad loads
      end
    end
    ret_val
  end

  def _list_services(type='service')
    clear_error
    ret_val = []
    Dir.foreach(SystemConfig.RunDir + '/' + type +'s/') do |contdir|
      yfn = SystemConfig.RunDir + '/' + type +'s/' + contdir + '/config.yaml'
      ret_val.push(contdir) if File.exist?(yfn)
    end
    ret_val
  end

  def _loadManagedService(service_name, service_type_dir)
    raise EnginesException.new(error_hash('No Service Name', service_type_dir)) if service_name.nil? || service_name.length == 0
    raise EnginesException.new(error_hash("no System api to attach ", @engines_api.to_s)) if @engines_api.service_api.nil?

    yam1_file_name = SystemConfig.RunDir + service_type_dir + service_name + '/running.yaml'
    raise EnginesException.new(error_hash('Engine File Locked', yam_file_name)) if is_container_conf_file_locked?(SystemConfig.RunDir + service_type_dir + service_name)
    unless File.exist?(yam1_file_name)
      raise EnginesException.new(error_hash('failed to create service file ', SystemConfig.RunDir + service_type_dir + '/' + service_name.to_s)) unless ContainerStateFiles.build_running_service(service_name, SystemConfig.RunDir + service_type_dir,@engines_api.system_value_access)
    end
    yaml_file = File.read(yam1_file_name)
    STDERR.puts('Panic nill  engine_api'  ) if @engines_api.nil?
    managed_service = SystemService.from_yaml(yaml_file, @engines_api.service_api) if service_type_dir ==  '/system_services/'
    managed_service = ManagedService.from_yaml(yaml_file, @engines_api.service_api)
    raise EnginesException.new(error_hash('Failed to load ' + yam1_file_name.to_s , yaml_file)) if managed_service.nil?
    managed_service
  end

  def setup_service_dirs(container)
    run_server_script('setup_service_dir' , container.container_name)
  end
end