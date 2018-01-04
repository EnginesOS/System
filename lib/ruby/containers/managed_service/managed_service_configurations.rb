module ManagedServiceConfigurations
  def run_configurator(configurator_params)
    configurator_params[:service_name] = @container_name
    raise EnginesException.new({error_mesg: 'No service variables', error_type: :error , params: configurator_params}) unless configurator_params.key?(:variables)
    raise EnginesException.new({error_mesg: 'service variables not a hash', error_type: :error , params: configurator_params}) unless configurator_params[:variables].is_a?(Hash)
    raise EnginesException.new(warning_hash('service not running ', configurator_params)) unless is_running?
    raise EnginesException.new(error_hash('service missing cont_userid ', configurator_params)) if check_cont_uid == false
    @container_api.run_configurator(self, configurator_params)
  end

  def retrieve_configurator(configurator_params)
    configurator_params[:service_name] = @container_name
    if  is_running? == false
    r = retrieve_service_configuration(configurator_params)
    STDERR.puts(' recevie ARGS ' + r.to_s)
    r
    else
      raise EnginesException.new(error_hash('service missing cont_userid ', configurator_params)) if check_cont_uid == false
     r = @container_api.retrieve_configurator(self, configurator_params)
      STDERR.puts(' recevie ARGS ' + r.to_s)
          r
    end
  end

  def retrieve_service_configuration(configurator_params)
    @container_api.retrieve_service_configuration(
    {service_name: @container_name,
      type_path: @type_path,
      publisher_namespace: @publisher_namespace,
      configurator_name: configurator_params[:configurator_name]
    })
  end

  def retrieve_service_configurations
    @container_api.retrieve_service_configurations(
    {service_name: @container_name,
      type_path: @type_path,
      publisher_namespace: @publisher_namespace })
  end

  def service_resource(what)
    #STDERR.puts('SERVICE RESOURCE' + self.container_name)
    @container_api.service_resource(self, what)
  end

end