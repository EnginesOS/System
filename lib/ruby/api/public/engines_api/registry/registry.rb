module PublicApiRegistry
  def orphaned_services_registry
    @core_api.orphaned_services_registry
  end

  def managed_services_registry
    @core_api.managed_services_registry
  end

  def managed_engines_registry
    @core_api.managed_engines_registry
  end

  def service_configurations_registry
    @core_api.service_configurations_registry
  end

  def shared_services_registry
    @core_api.shared_services_registry
  end
  def subservices_registry
    @core_api.subservices_registry
  end
end