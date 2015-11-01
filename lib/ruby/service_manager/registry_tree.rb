require_relative 'result_checks.rb'

module RegistryTree
  #@return [Tree::TreeNode] representing the orphaned services tree as dettached and frozen from the parent Tree
   #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
   def get_orphaned_services_tree
     test_and_lock_registry_result(@system_registry.orphaned_services_registry)
   end
 
   #@return [Tree::TreeNode] representing the managed services tree as dettached and frozen from the parent Tree
   #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
   def managed_service_tree
     test_and_lock_registry_result(@system_registry.services_registry)
   end
 
   #@return [Tree::TreeNode] representing the managed engines tree as dettached and frozen from the parent Tree
   #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
   def get_managed_engine_tree
     test_and_lock_registry_result(@system_registry.managed_engines_registry)
   end
 
   #@return [Tree::TreeNode] representing the services configuration tree as dettached and frozen from the parent Tree
   #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
   def service_configurations_tree
     test_and_lock_registry_result(@system_registry.service_configurations_registry)
   end
end