module ContainerConfigLoader
  def getManagedEngines
    container_store.all
  end

  def list_managed_engines
    container_store.all_names
  end

  def loadManagedEngine(engine_name)
    container_store.model(engine_name)
  end

  def getManagedServices
    service_store.all
  end

  def getSystemServices
    system_service_store.all
  end

  def list_managed_services
    service_store.all_names
  end

  def list_system_services
    system_service_store.all_names
  end

  def loadSystemService(name)
    system_service_store.model(name)
  end

  def loadManagedService(name)
    service_store.model(name)
  end

  def loadManagedUtility(name)
    utility_store.model(name)
  end

  protected

  def container_store
    Container::ManagedEngine.store
  end

  def utility_store
    Container::ManagedUtility.store
  end

  def service_store
    Container::ManagedService.store
  end

  def system_service_store
    Container::SystemService.store
  end
end