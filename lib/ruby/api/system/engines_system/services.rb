module Services
  
  def getManagedServices
      begin
        ret_val = []
        Dir.entries(SystemConfig.RunDir + '/services/').each do |contdir|
          yfn = SystemConfig.RunDir + '/services/' + contdir + '/config.yaml'
          if File.exist?(yfn) == true
            managed_service = loadManagedService(contdir)
            ret_val.push(managed_service) if managed_service
          end
        end
        return ret_val
      rescue StandardError => e
        log_exception(e)
      end
    end
    
  def list_managed_services
      clear_error
      ret_val = []
      Dir.entries(SystemConfig.RunDir + '/services/').each do |contdir|
        yfn = SystemConfig.RunDir + '/services/' + contdir + '/config.yaml'
        ret_val.push(contdir) if File.exist?(yfn)
      end
      return ret_val
    rescue StandardError => e
      log_exception(e)
      return ret_val
    end
    
  def loadSystemService(service_name)
    _loadManagedService(service_name,  '/system_services/')
  end

  def loadManagedService(service_name)
    s = engine_from_cache('/services/' + service_name)
            return s unless s.nil?            
   s = _loadManagedService(service_name,  '/services/')
    cache_engine('/services/' + service_name, s)
    return s
  end

  
    
  def _loadManagedService(service_name, service_type_dir)
  
    if service_name.nil? || service_name.length == 0
      @last_error = 'No Service Name'
      return false
    end
    yam1_file_name = SystemConfig.RunDir + service_type_dir + service_name + '/running.yaml'
    unless File.exist?(yam1_file_name)
      return log_error_mesg('failed to create service file ', SystemConfig.RunDir + service_type_dir + '/' + service_name.to_s) unless ContainerStateFiles.build_running_service(service_name, SystemConfig.RunDir + service_type_dir)
    end
    yaml_file = File.read(yam1_file_name)
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
    
end