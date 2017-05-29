module ManagedServiceConfigurations
  def run_configurator(configurator_params)
    configurator_params[:service_name] = @container_name
    raise EnginesException.new(error_hash('service not running ', configurator_params)) unless is_running?
    raise EnginesException.new(error_hash('service missing cont_userid ', configurator_params)) if check_cont_uid == false
    @container_api.run_configurator(self, configurator_params)
  end

  def retrieve_configurator(configurator_params)
    configurator_params[:service_name] = @container_name
    raise EnginesException.new(error_hash('service not running ', configurator_params)) if is_running? == false
    raise EnginesException.new(error_hash('service missing cont_userid ', configurator_params)) if check_cont_uid == false
    @container_api.retrieve_configurator(self, configurator_params)
  end

  def retrieve_service_configurations
    @container_api.retrieve_service_configurations_hashes(
    {service_name: @container_name,
      type_path: @type_path,
      publisher_namespace: @publisher_namespace })
  end

  def service_resource(what)
    STDERR.puts('SERVICE RESOURCE' + self.container_name)
    @container_api.service_resource(self, what)
  end

end