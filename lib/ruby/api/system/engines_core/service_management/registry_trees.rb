module RegistryTrees
  require_relative 'service_manager_access.rb'
  def orphaned_services_registry
    service_manager.orphaned_services_registry
  end

  def managed_services_registry
    service_manager.managed_services_registry
  end

  def managed_engines_registry
    service_manager.managed_engines_registry
  end

  def service_configurations_registry
    service_manager.service_configurations_registry
  end

  def get_shared_services_registry
    service_manager.shared_services_registry
  end

  def registry_root
    service_manager.registry_root
  end
end