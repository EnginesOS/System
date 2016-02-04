module ServiceOperations

  require_relative 'service_manager_access.rb'
  def signal_service_process(pid, sig, name)
    clear_error
    container = loadManagedService(name)
    test_docker_api_result(@docker_api.signal_container_process(pid, sig, container))
  end

  def force_reregister_attached_service(service_query)
    return false unless check_service_hash(service_query)
    check_sm_result(service_manager.force_reregister_attached_service(service_query))
  end

  def force_deregister_attached_service(service_query)
    return false unless check_service_hash(service_query)
    check_sm_result(service_manager.force_deregister_attached_service(service_query))
  end

  def force_register_attached_service(service_query)
    return false unless check_service_hash(service_query)
    check_sm_result(service_manager.force_register_attached_service(service_query))
  end

  # @return an [Array] of service_hashs of Active persistent services match @params [Hash]
  # :path_type :publisher_namespace
  def get_active_persistent_services(params)
    service_manager.get_active_persistent_services(params)
  end

  #Attach the service defined in service_hash [Hash]
  #@return boolean indicating sucess
  def create_and_register_service(service_hash)
    service_hash = SystemUtils.symbolize_keys(service_hash)
    p :attach_ing_create_and_egister_service
    p service_hash
    return log_error_mesg('register failed', service_hash) unless create_and_register_managed_service(service_hash)
    if service_hash[:type_path] == 'filesystem/local/filesystem'
      engine = loadManagedEngine(service_hash[:parent_engine])
      #return log_error_mesg('No such Engine',service_hash) unless engine.is_a?(ManagedEngine)
      engine.add_volume(service_hash) if engine.is_a?(ManagedEngine)
    end
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def dettach_service(service_hash)
    return false unless check_service_hash(service_hash)
    check_sm_result(service_manager.delete_service(service_hash))
  rescue StandardError => e
    log_exception(e)
  end

  # @ returns  complete service hash matching PNS,SP,PE,SH
  def retrieve_service_hash(query_hash)
    check_sm_result(service_manager.find_engine_service_hash(query_hash))
  end

  def list_providers_in_use
    check_sm_result(service_manager.list_providers_in_use)
  end

  #returns
  def find_service_consumers(service_query)
    return false unless check_service_hash(service_query)
    check_sm_result(service_manager.find_service_consumers(service_query))
  end

  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(service_hash)
    clear_error
    return false unless check_service_hash(service_hash)
    check_sm_result(service_manager.get_registered_against_service(service_hash))
  end

  def update_attached_service(service_hash)
    clear_error
    return false unless check_engine_service_hash(service_hash)
    check_sm_result(service_manager.update_attached_service(service_hash))
  end

  protected

  def create_and_register_managed_service(service_hash)
    SystemUtils.debug_output( "osapicreate_and_register_managed_service", service_hash)
    service_hash[:variables][:parent_engine] = service_hash[:parent_engine] unless service_hash[:variables].has_key?(:parent_engine)
    ServiceDefinitions.set_top_level_service_params(service_hash,service_hash[:parent_engine])
    return log_error_mesg('Service Hash missing details',service_hash) unless check_engine_service_hash(service_hash)
    return log_error_mesg('Attached Service passed no variables', service_hash) unless service_hash.key?(:variables)
    SystemUtils.debug_output( "calling service ", service_hash)
    return log_error_mesg('register failed', service_hash) unless check_sm_result(service_manager.create_and_register_service(service_hash))
    return true
  end

end