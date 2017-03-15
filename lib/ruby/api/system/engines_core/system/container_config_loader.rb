module ContainerConfigLoader
  def getManagedEngines
    @system_api.getManagedEngines
  end

  def loadManagedEngine(engine_name)
    @system_api.loadManagedEngine(engine_name)
  end

  def loadManagedService(service_name)
    @system_api.loadManagedService(service_name)
  end

  def loadManagedUtility(utility_name)
    @system_api.loadManagedUtility(utility_name)
  end
  
  def loadSystemService(service_name)
     @system_api.loadSystemService(service_name)
   end
   
  def getManagedServices
    @system_api.getManagedServices
  end

  def getSystemServices
    @system_api.getSystemServices
  end

  def list_managed_engines
    @system_api.list_managed_engines
  end

  def list_managed_services
    @system_api.list_managed_services
  end

  def list_system_services
    @system_api.list_system_services
  end

end