module ServiceOperations

  require_relative 'service_manager_access.rb'
  def signal_service_process(pid, sig, name)
    container = loadManagedService(name)
    @docker_api.signal_container_process(pid, sig, container)
  end

  def force_reregister_non_persistent_service(service_query)
    STDERR.puts('Service hash ' + service_query.to_s)
    check_service_hash(service_query)
    service_manager.force_reregister_non_persistent_service(service_query)
  end

  def force_deregister_non_persistent_service(service_query)
    STDERR.puts('Service hash ' + service_query.to_s)
    check_service_hash(service_query)
    service_manager.force_deregister_non_persistent_service(service_query)
  end

  def force_register_non_persistent_service(service_query)
    STDERR.puts('Service hash ' + service_query.to_s)
    check_service_hash(service_query)
    service_manager.force_register_non_persistent_service(service_query)
  end

  # @return an [Array] of service_hashs of Active persistent services match @params [Hash]
  # :path_type :publisher_namespace
  def get_active_persistent_services(params)
    service_manager.get_active_persistent_services(params)
  end

  #Attach the service defined in service_hash [Hash]
  # @return boolean indicating sucess
  def create_and_register_service(service_hash)
    check_service_hash(service_hash)
    SystemDebug.debug(SystemDebug.services, :attach_ing_create_and_egister_service, service_hash)
    create_and_register_managed_service(service_hash)
  end

  def dettach_service(service_hash)
    check_service_hash(service_hash)
    SystemDebug.debug(SystemDebug.services,:dettach_service, service_hash)
    service_manager.delete_and_remove_service(service_hash)
  end

  # @ returns  complete service hash matching PNS,SP,PE,SH
  def retrieve_service_hash(query_hash)
    retrieve_engine_service_hash(query_hash)
  end

  def providers_in_use
    service_manager.providers_in_use
  end

  #returns
  def find_service_consumers(service_query)
    check_service_hash(service_query)
    service_manager.find_service_consumers(service_query)
  end

  # @return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def registered_with_service(service_hash)
    check_service_hash(service_hash)
    service_manager.registered_with_service(service_hash)
  end

  def update_attached_service(service_hash)
    check_engine_service_hash(service_hash)
    ahash = retrieve_engine_service_hash(service_hash)
    raise EnginesException.new(error_hash("Cannot update a shared service",service_hash)) if ahash[:shared] == true
    service_manager.update_attached_service(service_hash)
  end

  def clear_service_from_registry(service, persistence=:non_persistent)
    service_manager.clear_service_from_registry({:parent_engine => service.container_name, :container_type => 'service', :persistence => persistence})
  end
#
#  def force_register_non_persistent_service(service_hash)
#    service_manager.force_register_non_persistent_service(service_hash)
#  end
#
#  def force_reregister_non_persistent_service(service_hash)
#    service_manager.force_reregister_non_persistent_service(service_hash)
#  end
#
#  def force_deregister_non_persistent_service(service_hash)
#    service_manager.force_deregister_non_persistent_service(service_hash)
#  end
  
  protected

  def create_and_register_managed_service(service_hash)
    raise EnginesException.new(error_hash('Attached Service passed no variables ' +  service_hash.to_s, service_hash)) unless service_hash.key?(:variables)
    SystemDebug.debug(SystemDebug.services, "osapicreate_and_register_managed_service", service_hash)
    service_hash[:variables][:parent_engine] = service_hash[:parent_engine] unless service_hash[:variables].has_key?(:parent_engine)
    set_top_level_service_params(service_hash, service_hash[:parent_engine])
    check_engine_service_hash(service_hash)
    if service_hash[:type_path] == 'filesystem/local/filesystem'
      begin
        engine = loadManagedEngine(service_hash[:parent_engine])
        engine.add_volume(service_hash) if engine.is_a?(ManagedEngine)
      rescue
        #will fail on build
      end
    end
    SystemDebug.debug(SystemDebug.services,"calling service ", service_hash)
    service_manager.create_and_register_service(service_hash)
  end

end