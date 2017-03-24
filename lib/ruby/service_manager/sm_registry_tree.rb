
#require_relative 'registry_client.rb'

module SmRegistryTree
  # @return [Tree::TreeNode] representing the orphaned services tree as dettached and frozen from the parent Tree
  # @return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def orphaned_services_registry
    system_registry_client.orphaned_services_registry
  end

  # @return [Tree::TreeNode] representing the managed services tree as dettached and frozen from the parent Tree
  # @return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def managed_services_registry
    system_registry_client.managed_services_registry
  end

  # @return [Tree::TreeNode] representing the managed engines tree as dettached and frozen from the parent Tree
  # @return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def managed_enginess_registry
    system_registry_client.managed_engines_registry
  end

  # @return [Tree::TreeNode] representing the services configuration tree as dettached and frozen from the parent Tree
  # @return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def service_configurations_registry
    system_registry_client.service_configurations_registry
  end

  # @return [Tree::TreeNode] representing the share servuces tree as dettached and frozen from the parent Tree
  # @return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def shared_services_registry
    system_registry_client.shared_services_registry
  end

 def registry_root()
    system_registry_client.registry_root()
  end
end