module ServiceConfigurations
  require_relative 'service_manager_access.rb'
  def retrieve_service_configuration(config)
    r = retrieve_configuration(config)
    return r
  end

  def get_service_configurations_hashes(service_hash)

    defs = SoftwareServiceDefinition.configurators(service_hash)

    return defs if defs.is_a?(EnginesError)
    avail = service_defs_to_configurations(defs,service_hash)
    return avail if avail.is_a?(EnginesError)

    configured = service_manager.get_service_configurations_hashes(service_hash)

    return configured  if configured.is_a?(EnginesError)
    if configured.is_a?(Array)
      configured.each do | configuration |
        avail[ configuration[:configurator_name].to_sym ] = configuration
      end
    end
    avail.values
  end

  def get_pending_service_configurations_hashes(service_hash)
    service_manager.get_pending_service_configurations_hashes(service_hash)
  end

  def update_service_configuration(service_param)
    # configurator = ConfigurationsApi.new(self)
    r = ''
    r = update_configuration_on_service(service_param)
    return service_manager.update_service_configuration(service_param) unless r.is_a?(EnginesError)
    return log_error_mesg('Failed to update configuration on service ' + service_param.to_s, r)

  end

  def retrieve_configuration(service_param)
    return log_error_mesg('Missing service name', service_param) unless service_param.key?(:service_name)
    service = loadManagedService(service_param[:service_name])
    return service unless service.is_a?(ManagedService)
    if service.is_running?
      ret_val = service.retrieve_configurator(service_param)
      #    STDERR.puts('Retrived retrieve_configuration '+ service_param.to_s + ret_val.class.name + ':' + ret_val.to_s )
      return retval unless ret_val.is_a?(Hash)
    else
      #  STDERR.puts('Retrived retrieve_configuration '+ service_param.to_s + ret_val.class.name + ':' + ret_val.to_s )
      ret_val = get_service_configuration(service_param)
    end

    return ret_val
  end

  private

  def  definition_params_to_variables(params)
    variables =  {}
    params.each do | param_name|
      variables[param_name] = ''
    end
    variables
  end

  def service_defs_to_configurations(defs, service_hash)
    avail = {}
    defs.each_value do |definition|
      definition_key = definition[:name].to_sym
      avail[definition_key] = {}
      avail[definition_key][:service_name] = service_hash[:service_name]
      avail[definition_key][:type_path] = service_hash[:type_path]
      avail[definition_key][:publisher_namespace] = service_hash[:publisher_namespace]

      avail[definition_key][:configurator_name] = definition[:name]
      avail[definition_key][:variables] = definition_params_to_variables(definition[:params].keys)
      avail[definition_key][:no_save] = definition[:no_save]
    end
    avail
  end

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
      service_param[:pending] = true
      STDERR.puts("core update  config " + service_param.to_s)
      service_manager.update_service_configuration(service_param)
      return true
    end
    if service_param.key?(:pending)
      service_param.delete(:pending)
    end
    # set config on reunning service
    configurator_result =  service.run_configurator(service_param)

    return log_error_mesg('Service configurator erro@core_api.r Got:', configurator_result.to_s, " For:" +service_param.to_s) unless configurator_result.is_a?(Hash)
    service_manager.update_service_configuration(service_param)
    return log_error_mesg('Service configurator error @core_ap Got:', configurator_result.to_s, " For:" +service_param.to_s ) unless configurator_result[:result] == 0 || configurator_result[:stderr].start_with?('Warning')

    return true
  end

end