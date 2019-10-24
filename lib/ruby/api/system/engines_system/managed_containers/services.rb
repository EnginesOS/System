require_relative 'cache'

module Services
  def getManagedServices
    get_services_by_type('service')
  end

  def getSystemServices
    get_services_by_type('system_service')
  end

  def list_managed_services
    _list_services
  end

  def list_system_services
    _list_services('system_service')
  end

  def loadSystemService(service_name)
    _loadManagedService(service_name, '/system_services/')
  end

  def loadManagedService(service_name)
    s = cache.container('services/' + service_name)
    unless s.is_a?(Container::ManagedService)
      if service_name == 'system'
        s = loadSystemService(service_name)
      else
        s = _loadManagedService(service_name, '/services/')
        ts = File.mtime(SystemConfig.RunDir + '/services/' + service_name + '/running.yaml')
        cache.add(s, ts)
      end
    end
    s
  end


  private

  def cache
    Container::Cache.instance
  end

  def get_services_by_type(type = 'service')
    services = _list_services(type)
    ret_val = []
    if services.is_a?(Array)
      services.each do |service_name|
        begin
          service = loadManagedService(service_name) if type == 'service'
          service = loadSystemService(service_name) if type == 'system_service'
          ret_val.push(service) if service.is_a?(Container::ManagedService)
        rescue # skip bad loads
        end
      end
    end
    ret_val
  end

  def _list_services(type='service')
    ret_val = []
    Dir.foreach(SystemConfig.RunDir + '/' + type + 's/') do |contdir|
      begin
        yfn = SystemConfig.RunDir + '/' + type + 's/' + contdir + '/config.yaml'
        ret_val.push(contdir) if File.exist?(yfn)
      rescue # skip bad loads
      end
    end
    ret_val
  end

  def _loadManagedService(service_name, service_type_dir)
    raise EnginesException.new(error_hash('No Service Name', service_type_dir)) if service_name.nil? || service_name.length == 0

    yam1_file_name = SystemConfig.RunDir + service_type_dir + service_name + '/running.yaml'
   # raise EnginesException.new(error_hash('Engine File Locked', yam1_file_name)) if is_container_conf_file_locked?(SystemConfig.RunDir + service_type_dir + service_name)
    unless File.exist?(yam1_file_name)
      raise EnginesException.new(error_hash('failed to create service file ', SystemConfig.RunDir + service_type_dir + '/' + service_name.to_s)) unless build_running_service(service_name, SystemConfig.RunDir + service_type_dir) 
    end
    lock_container_conf_file(SystemConfig.RunDir + service_type_dir + service_name)
    yaml_file = File.read(yam1_file_name)
    unlock_container_conf_file(SystemConfig.RunDir + service_type_dir + service_name)
    STDERR.puts('Panic nill  engine_api') if core.nil?
    managed_service = if service_type_dir ==  '/system_services/'
      Container::SystemService.from_yaml(yaml_file)
    else
      Container::ManagedService.from_yaml(yaml_file)
    end
    raise EnginesException.new(error_hash('Failed to load ' + yam1_file_name.to_s , yaml_file)) if managed_service.nil?
    managed_service
  end

  def setup_service_dirs(container)
    run_server_script('setup_service_dir', container.container_name)
  end
end
