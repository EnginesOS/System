module SmServiceConfigurations
  def update_service_configuration(config_hash)
    #load service definition and from configurators definition and if saveable save
    service_definition = software_service_definition(config_hash)
    raise EnginesException.new(error_hash('Missing Service definition file ', config_hash))  unless service_definition.is_a?(Hash)
    config_hash[:no_save] = service_definition[:no_save]
    SystemDebug.debug(SystemDebug.services,:update_service, service_definition)
    raise EnginesException.new(error_hash('Missing Configurators in service definition', config_hash)) unless service_definition.key?(:configurators)
    configurators = service_definition[:configurators]
    raise EnginesException.new(error_hash('Missing Configurator ', config_hash[:configurator_name])) unless configurators.key?(config_hash[:configurator_name].to_sym)
    configurator_definition = configurators[config_hash[:configurator_name].to_sym]
    unless configurator_definition.key?(:no_save) && configurator_definition[:no_save]
      return system_registry_client.update_service_configuration(config_hash)
    else
      return true
    end
  rescue StandardError => e
    log_exception(e)
    raise e
  end

  # @Returns an Array of Configuration hashes resgistered against the service [String] service_name
  
  def retrieve_service_configurations_hashes(service_name)
    system_registry_client.retrieve_service_configurations_hashes(service_name)
  end

  def retrieve_service_configuration(service_name)
    system_registry_client.retrieve_service_configuration(service_name)
  end

  def pending_service_configurations_hashes(service_name)
    hashes = system_registry_client.retrieve_service_configurations_hashes(service_name)
    return unless hashes.is_a?(Array)
    retval = []
    hashes.each do |config|
      retval.push(config) if config.key?(:pending)
    end
    retval
  end
end