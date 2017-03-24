module PublicApiRegistry
  def orphaned_services_registry
    @core_api.orphaned_services_registry
  end

  def managed_services_registry
    @core_api.managed_services_registry
  end

  def managed_enginess_registry
    @core_api.managed_enginess_registry
  end

  def service_configurations_registry
    @core_api.service_configurations_registry
  end

  def get_shared_services_registry
    @core_api.get_shared_services_registry
  end
end