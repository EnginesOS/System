class EnginesCore
  def retrieve_service_configuration(config)
    retrieve_configuration(config)
  end

  def retrieve_service_configurations(service_hash)
    defs = SoftwareServiceDefinition.configurators(service_hash)
    avail = service_defs_to_configurations(defs, service_hash)
    configured = service_manager.retrieve_service_configurations(service_hash)
    if configured.is_a?(Array)
      configured.each do | configuration |
        avail[ configuration[:configurator_name].to_sym ] = configuration
      end
    end
    avail.values
  end

  def pending_service_configurations_hashes(service_hash)
    service_manager.pending_service_configurations_hashes(service_hash)
  end

  def update_service_configuration(service_param)
    update_configuration_on_service(service_param)
    #This is down above    service_manager.update_service_configuration(service_param)
  end

  def retrieve_configuration(service_param)
    raise EnginesException.new(error_hash('Missing service name', service_param)) unless service_param.key?(:service_name)
    service = loadManagedService(service_param[:service_name])
    if service.is_running?
      ret_val = service.retrieve_configurator(service_param)
    else
      ret_val = retrieve_service_configuration(service_param)
    end
    ret_val
  end

  def retrieve_service_configuration(service_param)
    service_manager.retrieve_service_configuration(service_param)
  end

  def service_resource(service_name, what)
    service_manager.service_resource(service_name, what)
  end

  private

  def definition_params_to_variables(params)
    variables =  {}
    params.each do | param_name|
      variables[param_name] = ''
    end
    variables
  end

  def service_defs_to_configurations(defs, service_hash)
    avail = {}
    unless defs.nil?
      defs.each_value do |definition|
        if definition[:params].nil?
          variables = nil
        else
          variables = definition_params_to_variables(definition[:params].keys)
        end
        definition_key = definition[:name].to_sym

        avail[definition_key] = {
          service_name: service_hash[:service_name],
          type_path: service_hash[:type_path],
          publisher_namespace: service_hash[:publisher_namespace],
          configurator_name: definition[:name],
          variables: variables,
          no_save: definition[:no_save]
        }
      end
    end
    avail
  end

  def update_configuration_on_service(service_param)
    raise EnginesException.new(error_hash('Missing Service name', service_param)) unless service_param.key?(:service_name)
    begin
      service = loadManagedService(service_param[:service_name])
    rescue
      service = loadSystemService(service_param[:service_name])
    end
    service_param[:publisher_namespace] = service.publisher_namespace.to_s  # need as saving in config tree
    service_param[:type_path] = service.type_path.to_s
    # setting stopped contianer is ok as call can know the state, used to boot strap a config
    unless service.is_running?
      service_param[:pending] = true
      service_manager.update_service_configuration(service_param)
    else
      if service_param.key?(:pending)
        service_param.delete(:pending)
      end
      # set config on reunning service
      configurator_result = service.run_configurator(service_param)
      raise EnginesException.new(error_hash('Service configurator erro@core_api.r Got:' + configurator_result.to_s, " For:" +service_param.to_s)) unless configurator_result.is_a?(Hash)
      service_manager.update_service_configuration(service_param)
      raise EnginesException.new(error_hash('Service configurator error @core_ap Got:' + configurator_result.to_s, " For:" +service_param.to_s )) unless configurator_result[:result] == 0 || configurator_result[:stderr].start_with?('Warning')
    end
    true
  end

end