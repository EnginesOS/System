module ManagedServiceConfigurations
    
  def run_configurator(configurator_params)
    @container_api.run_configurator(self, configurator_params)
  end
  
  def retrieve_configurator(configurator_params)
    @container_api.retrieve_configurator(self, configurator_params)
  end

end