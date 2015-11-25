module ManagedServiceConfigurations
    
  def run_configurator(configurator_params)
    return log_error_mesg('service not running ',configurator_params) unless is_running?
    return log_error_mesg('service missing cont_userid ',configurator_params) if check_cont_uid == false
    @container_api.run_configurator(self, configurator_params)
  end
  
  def retrieve_configurator(configurator_params)
    return log_error_mesg('service not running ',params) if is_running? == false
    return log_error_mesg('service missing cont_userid ',params) if check_cont_uid == false
    @container_api.retrieve_configurator(self, configurator_params)
  end

end