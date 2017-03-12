module Services
  def getManagedServices
    get_services_by_type(type='service')
  end
  
  def getSystemServices
    get_services_by_type(type='system_service')
  end
  

  
  def list_managed_services
    _list_services  
  rescue StandardError => e
     log_exception(e)    
  end
  def list_system_services
    _list_services('system_service')  
  rescue StandardError => e
     log_exception(e)    
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
      return s if is_a?(EnginesError)
      ts = File.mtime(SystemConfig.RunDir + '/services/' + service_name + '/running.yaml')
      cache_engine(s, ts)
    end
    return s
  rescue StandardError => e
    return nil
  end
  
  private 
  
  def get_services_by_type(type='service')
    ret_val = []
    services = _list_services(type)
    services.each do |service_name |
      service = loadManagedService(service_name) if type == 'service'
      service = loadSystemService(service_name) if type == 'system_service'
      ret_val.push(service) if service.is_a?(ManagedService)
    end
    return ret_val
  end
  
  def _list_services(type='service')
     clear_error
        ret_val = []
        Dir.foreach(SystemConfig.RunDir + '/' + type +'s/') do |contdir|
          yfn = SystemConfig.RunDir + '/' + type +'s/' + contdir + '/config.yaml'
          ret_val.push(contdir) if File.exist?(yfn)
        end
        return ret_val
   end

  def _loadManagedService(service_name, service_type_dir)

    return log_error_mesg('No Service Name',service_type_dir) if service_name.nil? || service_name.length == 0
    return log_error_mesg("no System api to attach ", @engines_api.to_s) if @engines_api.service_api.nil?
    
    yam1_file_name = SystemConfig.RunDir + service_type_dir + service_name + '/running.yaml'
    return log_error_mesg('Engine File Locked',yam_file_name) if is_container_conf_file_locked?(SystemConfig.RunDir + service_type_dir + service_name)
    unless File.exist?(yam1_file_name)
      return log_error_mesg('failed to create service file ', SystemConfig.RunDir + service_type_dir + '/' + service_name.to_s) unless ContainerStateFiles.build_running_service(service_name, SystemConfig.RunDir + service_type_dir,@engines_api.system_value_access)
    end
    yaml_file = File.read(yam1_file_name)
   STDERR.puts('Panic nill  engine_api'  ) if @engines_api.nil?
    managed_service = SystemService.from_yaml(yaml_file, @engines_api.service_api) if service_type_dir ==  '/system_services/'
    managed_service = ManagedService.from_yaml(yaml_file, @engines_api.service_api)
    return log_error_mesg('Failed to load', yaml_file) if managed_service.nil?
    
    managed_service
  rescue StandardError => e
    if service_name.nil? == false
      unless managed_service.nil?
        managed_service.last_error = ('Failed To get Managed Engine ' + service_name.to_s + ' ' + e.to_s)
        log_exception(e)
      end
    else
      log_error_mesg('nil Service Name', service_name)
    end
    log_exception(e)
  end
  
  def setup_service_dirs(container)
    run_server_script('setup_service_dir' , container.container_name)
  
  end
end