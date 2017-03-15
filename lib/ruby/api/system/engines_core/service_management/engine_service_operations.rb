module EngineServiceOperations
  require_relative 'service_manager_access.rb'
  def engine_persistent_services(container_name)
    params = {
      parent_engine:  container_name,
      persistent:  true,
      container_type: 'container'
    }
    SystemDebug.debug(SystemDebug.services, :engine_persistent_services, params)
    r = service_manager.get_engine_persistent_services(params)

    r
  rescue StandardError => e
    log_exception(e,container_name)
  end

  def engines_services_to_backup(engine_name)
    #   STDERR.puts('Backup for ' + engine_name )
    engine_persistent_services(engine_name)
  end

  def service_persistent_services(service_name)
    params = {
      parent_engine: service_name,
      persistent: true,
      container_type: 'service'
    }
    SystemDebug.debug(SystemDebug.services,  :engine_persistent_services, params)
    service_manager.get_engine_persistent_services(params)
  rescue StandardError => e
    log_exception(e,service_name)
  end

  def service_attached_services(service_name)
    params = {
      parent_engine: service_name,
      container_type: 'service'
    }
    find_engine_services_hashes(params)
  rescue StandardError => e
    log_exception(e,service_name)
  end

  def engine_attached_services(container_name)
    params = {
      parent_engine: service_name,
      container_type: 'container'
    }
    find_engine_services_hashes(params)
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
    r = []
    return r unless (r = check_engine_hash(service_hash))
    service_manager.get_engine_persistent_services(service_hash)
  rescue StandardError => e
    log_exception(e,service_hash)
  end

  def find_engine_services(service_query)
    r = ''
    return r unless  (r = check_engine_hash(service_query))
    find_engine_services_hashes(service_query)
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

    unless service_hash.key?(:existing_service)
      existing = service_hash
      existing[:parent_engine] = existing[:owner]
      existing = get_service_entry(existing)
      return existing if existing.is_a?(EnginesError)
      params[:existing_service] = existing
    end

    trim_to_editable_variables(params[:existing_service])
    params[:variables].keys do | k |
      next unless params[:existing_service][:variables].keys(k)
      params[:variables][k] = params[:existing_service][:variables][k]
    end
    r = attach_existing_service_to_engine(params)
    unless r.is_a?(EnginesError)
      if service_hash[:type_path] == 'filesystem/local/filesystem'
        result = add_file_share(params)
        return log_error_mesg('failed to create fs',self) if result.is_a?(EnginesError)
      end
      return true
    end
    r
  end

  def add_file_share(service_hash)
    SystemDebug.debug(SystemDebug.services, 'Add File Service ' + service_hash[:variables][:name].to_s + ' ' + service_hash.to_s)
    # service_hash = Volume.complete_service_hash(service_hash)

    SystemDebug.debug(SystemDebug.services,'complete_VOLUME_FOR SHARE_service_hash', service_hash)
    engine = loadManagedEngine(service_hash[:parent_engine])
    return engine if engine.is_a?(EnginesError)
    engine.add_shared_volume(service_hash)

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
    args = ['/home/get_pubkey.sh', cmd]
    result = exec_in_container({:container => container, :command_line => args, :log_error => true, :timeout =>30 , :data=>''})
    return result[:stdout] if result.is_a?(Hash) &&result[:result] == 0
    log_error_mesg('Get pub key failed',result)
    service_manager.load_service_pubkey(container, cmd)
  rescue StandardError => e
    log_exception(e)
  end
  
  
def remove_engine(engine_name, reinstall = false)
    r = ''
    engine = loadManagedEngine(engine_name)
    SystemDebug.debug(SystemDebug.containers,:delete_engines,engine_name,engine, :resinstall,reinstall)
    params = {
      engine_name: engine_name,
      container_type: 'container', # Force This
      parent_engine: engine_name,
      reinstall: reinstall
    }
    unless engine.is_a?(ManagedEngine) # DO NOT MESS with this logi used in roll back and only works if no engine DO NOT MESS with this logic
      return true if service_manager.remove_engine_from_managed_engine(params)
      return log_error_mesg('Failed to find Engine',params)
    end

   #  service_manager.remove_managed_services(params)#remove_engine_from_managed_engines_registry(params)
     service_manager.remove_engine_services(params)
      engine.delete_image if engine.has_image? == true
  SystemDebug.debug(SystemDebug.containers,:engine_image_deleted,engine)
      return r if reinstall == true
      return engine.delete_engine
     r
end

end