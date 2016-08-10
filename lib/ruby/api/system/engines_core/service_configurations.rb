module ServiceConfigurations
  require_relative 'service_manager_access.rb'
  
  def retrieve_service_configuration(config)
    #     c = ConfigurationsApi.new(self)
    #     r = c.
    r = retrieve_configuration(config)
  #  return log_error_mesg('Configration failed ' +  last_error.to_s, r) unless r.is_a?(Hash)
    return r
  end

  def get_service_configurations_hashes(service_hash)
    
    avail = SoftwareServiceDefinition.configurators(service_hash)
    return avail if avail.is_a?(EnginesError) 
    
    
    STDERR.puts(' avail definitions ' +  avail.to_s)
    
    configured = service_manager.get_service_configurations_hashes(service_hash)
    STDERR.puts('configureddefinitions ' +  configured.to_s)
    return configured  if configured.is_a?(EnginesError) 
    configured.each do | configuration |
      avail[ configuration[:configurator_name] ] = configuration
 
    end
   
    avail.values
    
  end

  def get_pending_service_configurations_hashes(service_hash)
    service_manager.get_pending_service_configurations_hashes(service_hash)
  end
  
  

  def update_service_configuration(service_param)
    # configurator = ConfigurationsApi.new(self)
    r = ''
    return r unless (r = update_configuration_on_service(service_param))
    return  service_manager.update_service_configuration(service_param)

  end

 

  def retrieve_configuration(service_param)
    return log_error_mesg('Missing service name', service_param) unless service_param.key?(:service_name)
    service = loadManagedService(service_param[:service_name])
    return service unless service.is_a?(ManagedService)
    if service.is_running?
      ret_val = service.retrieve_configurator(service_param)
      return retval unless ret_val.is_a?(Hash)
    else
      return get_service_configuration(service_param)
    end

    return ret_val
  end
  
  private
   
  def get_service_configuration(service_param)
    service_manager.get_service_configuration(service_param)
  end
  
  def update_configuration_on_service(service_param)
     return log_error_mesg('Missing Service name',service_param) unless service_param.key?(:service_name)
     service = loadManagedService(service_param[:service_name])
       return service  unless service.is_a?(ManagedService)
     service_param[:publisher_namespace] = service.publisher_namespace.to_s  # need as saving in config tree
     service_param[:type_path] = service.type_path.to_s
     # setting stopped contianer is ok as call can know the state, used to boot strap a config
     unless service.is_running?
       service_param[:pending]= true        
       return true
     end
     if service_param.key?(:pending)
       service_param.delete(:pending)
     end
     # set config on reunning service

     configurator_result =  service.run_configurator(service_param)
     return log_error_mesg('Service configurator erro@core_api.r incorrect result type ', configurator_result.to_s) unless configurator_result.is_a?(Hash)
 
     return log_error_mesg('Service configurator error ', configurator_result.to_s) unless configurator_result[:result] == 0 || configurator_result[:stderr].start_with?('Warning')
     return true
   end
  
end