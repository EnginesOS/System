
require_relative 'registry_client.rb'

module SmRegistryTree
  #@return [Tree::TreeNode] representing the orphaned services tree as dettached and frozen from the parent Tree
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def get_orphaned_services_tree
    system_registry_client.orphaned_services_registry
  rescue StandardError => e
    handle_exception(e)
  end

  #@return [Tree::TreeNode] representing the managed services tree as dettached and frozen from the parent Tree
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def managed_service_tree
    system_registry_client.services_registry
  rescue StandardError => e
    handle_exception(e)
  end

  #@return [Tree::TreeNode] representing the managed engines tree as dettached and frozen from the parent Tree
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def get_managed_engine_tree
    system_registry_client.managed_engines_registry
  rescue StandardError => e
    handle_exception(e)
  end

  #@return [Tree::TreeNode] representing the services configuration tree as dettached and frozen from the parent Tree
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def service_configurations_tree
    system_registry_client.service_configurations_registry
  rescue StandardError => e
    handle_exception(e)
  end

  #@return [Tree::TreeNode] representing the share servuces tree as dettached and frozen from the parent Tree
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def shares_tree
    system_registry_client.shares_registry_tree
  rescue StandardError => e
    handle_exception(e)
  end

 def get_registry()
    system_registry_client.get_registry()
  rescue StandardError => e
   handle_exception(e)
  end
end