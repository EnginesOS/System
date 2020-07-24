#require_relative 'registry_client.rb'
class ServiceManager  
  # @return [Tree::TreeNode] representing the orphaned services tree as dettached and frozen from the parent Tree
  def orphaned_services_registry
    system_registry_client.orphaned_services_registry
  end

  # @return [Tree::TreeNode] representing the managed services tree as dettached and frozen from the parent Tree

  def managed_services_registry
    system_registry_client.managed_services_registry
  end

  # @return [Tree::TreeNode] representing the managed engines tree as dettached and frozen from the parent Tree

  def managed_engines_registry
    system_registry_client.managed_engines_registry
  end

  # @return [Tree::TreeNode] representing the services configuration tree as dettached and frozen from the parent Tree

  def service_configurations_registry
    system_registry_client.service_configurations_registry
  end

  # @return [Tree::TreeNode] representing the share servuces tree as dettached and frozen from the parent Tree

  def shared_services_registry
    system_registry_client.shared_services_registry
  end

  def subservices_registry
    system_registry_client.subservices_registry
  end
  
  def registry_root()
    system_registry_client.registry_root()
  end
end