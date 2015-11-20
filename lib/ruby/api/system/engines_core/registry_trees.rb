module RegistryTrees
  require_relative 'service_manager_access.rb'
  
  def get_orphaned_services_tree
    service_manager.get_orphaned_services_tree
  end

  def managed_service_tree
    check_sm_result(service_manager.managed_service_tree)
  end

  def get_managed_engine_tree
    check_sm_result(service_manager.get_managed_engine_tree)
  end

  def get_configurations_tree
    check_sm_result(service_manager.service_configurations_tree)
  end

end