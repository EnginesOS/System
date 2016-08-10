module ManagedServiceConfigurations
    
  def run_configurator(configurator_params)
    configurator_params[:service_name] = @container_name
    return log_error_mesg('service not running ',configurator_params) unless is_running?
    return log_error_mesg('service missing cont_userid ',configurator_params) if check_cont_uid == false
    @container_api.run_configurator(self, configurator_params)
  end
  
  def retrieve_configurator(configurator_params)
    configurator_params[:service_name] = @container_name
    return log_error_mesg('service not running ',configurator_params) if is_running? == false
    return log_error_mesg('service missing cont_userid ',configurator_params) if check_cont_uid == false
    @container_api.retrieve_configurator(self, configurator_params)
  end
  def get_service_configurations
      @container_api.get_service_configurations_hashes(
        {service_name: @container_name,
          type_path: @type_path, 
          publisher_namespace: 
          @publisher_namespace })
end
end