module SmServiceInfo
  ###READERS
  #list the Provider namespaces as an Array of Strings
  #@return [Array]
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def list_providers_in_use
    system_registry_client.list_providers_in_use
  rescue StandardError => e
    handle_exception(e)
  end

  def is_service_running?(service_name)
    service = @core_api.loadManagedService(service_name)
    return service unless service.is_a?(ManagedService)
    service.is_running?
  rescue StandardError => e
    handle_exception(e)
  end

  #Test whether a service hash is registered
  #@return's false on failure with error (if applicable) accessible from this object's  [ServiceManager] last_error method
  def service_is_registered?(service_hash)
    system_registry_client.service_is_registered?(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  def all_engines_registered_to(service_type)
    system_registry_client.all_engines_registered_to(service_type)
  rescue StandardError => e
    handle_exception(e)
  end

  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(params)
    clear_error
    system_registry_client.get_registered_against_service(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def get_service_entry(service_hash)
    system_registry_client.get_service_entry(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end

end