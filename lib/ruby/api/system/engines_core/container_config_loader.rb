module ContainerConfigLoader
  def getManagedEngines
      test_system_api_result(@system_api.getManagedEngines)
    end

    def loadManagedEngine(engine_name)
      test_system_api_result(@system_api.loadManagedEngine(engine_name))
    end
  
    def loadManagedService(service_name)
      test_system_api_result(@system_api.loadManagedService(service_name))
    end
  
    def getManagedServices
      test_system_api_result(@system_api.getManagedServices)
    end
  
   
  def list_managed_engines
    test_system_api_result(@system_api.list_managed_engines)
  end

  def list_managed_services
    test_system_api_result(@system_api.list_managed_services)
  end
  
end