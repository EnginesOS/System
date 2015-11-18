module FetchTrees
  def get_managed_engine_tree
     @core_api.get_managed_engine_tree
   end
 
   def get_configurations_tree
     @core_api.get_configurations_tree
   end
 
   def managed_service_tree
     fetch_managed_service_tree
   end
 
   def fetch_managed_service_tree
     p :managed_service_tree
     @core_api.managed_service_tree
   end
 
   def get_orphaned_services_tree
     @core_api.get_orphaned_services_tree
   end
end