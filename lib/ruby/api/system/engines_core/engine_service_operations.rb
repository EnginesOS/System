module EngineServiceOperations
  require_relative 'service_manager_access.rb'
  def engine_persistent_services(container_name)
    params = {}
    params[:parent_engine] = container_name
    params[:persistent] = true
    params[:container_type] ='container'
    SystemDebug.debug(SystemDebug.services, :engine_persistent_services, params)
    return service_manager.get_engine_persistent_services(params)
  rescue StandardError => e
    log_exception(e,container_name)
  end
  
  def service_persistent_services(service_name)
    params = {}
    params[:parent_engine] = service_name
    params[:persistent] = true
    params[:container_type] ='service'
    SystemDebug.debug(SystemDebug.services,  :engine_persistent_services, params)
    return service_manager.get_engine_persistent_services(params)
  rescue StandardError => e
    log_exception(e,service_name)
  end
  
  def service_attached_services(service_name)
     params = {}
     params[:parent_engine] = service_name
     params[:container_type] = 'service'
     return service_manager.find_engine_services_hashes(params)
   rescue StandardError => e
     log_exception(e,service_name)
   end
  
  def engine_attached_services(container_name)
    params = {}
    params[:parent_engine] = container_name
    params[:container_type] = 'container'
    return service_manager.find_engine_services_hashes(params)
  rescue StandardError => e
    log_exception(e,container_name)
  end

  def service_is_registered?(service_hash)
    r = ''
    return r unless  ( r = check_service_hash(service_hash))
    service_manager.service_is_registered?(service_hash)
    rescue StandardError => e
      log_exception(e,service_hash)
  end

  def get_engine_persistent_services(service_hash)
    r = ''
    return r unless (r = check_engine_hash(service_hash))
    service_manager.get_engine_persistent_services(service_hash)
    rescue StandardError => e
      log_exception(e,service_hash)
  end

  def find_engine_services(service_query)
    r = ''
    return r unless  (r = check_engine_hash(service_query))
    service_manager.find_engine_services_hashes(service_query)
    rescue StandardError => e
      log_exception(e,service_query)
    #return sm.find_engine_services(params)
  end
  
  def attach_existing_service_to_engine(params)
    r = ''
     SystemDebug.debug(SystemDebug.services,'core attach existing service', params)
    return r unless (r = check_engine_hash(params))
      
    service_manager.attach_existing_service_to_engine(params)
    rescue StandardError => e
      log_exception(e,params)
 
   end
  def connect_share_service(service_hash)
  params =  service_hash.dup
  STDERR.puts(' SHARE Existing ' + service_hash.to_s)
    existing = service_hash
    existing[:parent_engine] = existing[:owner]
    existing =  find_engine_services(existing)
    STDERR.puts(' SHARE Existing ' + existing.to_s)
      params[:existing_service] = existing
      trim_to_editable_variables(params)
      if attach_existing_service_to_engine(params)
        if service_hash[:type_path] == 'filesystem/local/filesystem'
          result = add_file_share(service_hash)
         log_error_mesg('failed to create fs',self) unless result
        end       
        return true
      end
    end 
    
  def add_file_share(service_hash)
     SystemDebug.debug(SystemDebug.builder, 'Add File Service ' + service_hash[:variables][:name].to_s + ' ' + service_hash.to_s)
     #  Default to engine
   
     service_hash = Volume.complete_service_hash(service_hash)
     SystemDebug.debug(SystemDebug.builder,:complete_VOLUME_service_hash, service_hash)
#    if service_hash[:share] == true
#      @volumes[service_hash[:service_owner] + '_' + service_hash[:variables][:service_name]] = vol
#    else
#      @volumes[service_hash[:variables][:service_name]] = Volume.volume_hash(service_hash)
#    end
     return true
   rescue StandardError => e
     SystemUtils.log_exception(e)
   end
   
    
  def trim_to_editable_variables(params)
    variables = SoftwareServiceDefinition.consumer_params(params)
    variables.values do |variable |
      key = variable[:name]
      params[:variables].delete(key) if variable[:immutable] == true
    end
    rescue StandardError => e
    log_exception(e,params,variables)
  end
  def get_service_pubkey(engine, cmd)

    container = loadManagedService(engine)
    return container if container.is_a?(EnginesError)
    
    return service_manager.load_service_pubkey(container, cmd) unless container.is_running?

      args = []
      args[0] = '/home/get_pubkey.sh'
      args[1] = cmd

result =  exec_in_container({:container => container, :command_line => args, :log_error => true, :timeout =>30 , :data=>''}) 
  
STDERR.puts('RESUTL 1 ' + result.to_s)
    return result unless result.is_a?(Hash)
STDERR.puts('RESUTL 2' + result.to_s)
    return result[:stdout] if result[:result] == 0
STDERR.puts('RESUTL 3' + result.to_s)
    log_error_mesg('Get pub key failed',result)
return service_manager.load_service_pubkey(container, cmd)
rescue StandardError => e
  log_exception(e)  
      
   # docker exec ' + service + ' /home/get_pubkey.sh ' + cmd
  end

end