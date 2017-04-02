module SmServiceInfo
  ###READERS
  #list the Provider namespaces as an Array of Strings
  # @return [Array]

  def providers_in_use
    system_registry_client.providers_in_use
  end

  def is_service_running?(service_name)
    @core_api.loadManagedService(service_name).is_running?
  end

  #Test whether a service hash is registered

  def service_is_registered?(service_hash)
    system_registry_client.service_is_registered?(service_hash)
  end

  def all_engines_registered_to(service_type)
    system_registry_client.all_engines_registered_to(service_type)
  end

  # @return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def registered_with_service(params)
    system_registry_client.registered_with_service(params)
  end

  def get_service_entry(service_hash)
    system_registry_client.get_service_entry(service_hash)
  end

end