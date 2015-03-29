#Module of methods to handle the Managed Engine Registry branch
module ManagedEnginesRegistry
  #Returns the engine node when supplied with params containing only :engine_name 
  #Returns service_type node when supplied with params  :engine_name and :type_path
  #Returns service node when supplied with params  :engine_name :type_path and :service_handle
  def find_engine_services(params)
      engine_node = managed_engine_tree[params[:parent_engine]]
  
      if params.has_key?(:type_path) && params[:type_path] != nil
        services = get_type_path_node(engine_node,params[:type_path]) #engine_node[params[:type_path]]
        if services != nil  && params.has_key?(:service_handle) && params[:service_handle] != nil
          service = services[params[:service_handle]]
          return service
        else
          return services
        end
      else
        return engine_node
      end
    end
    
    #@return all service_hashs for :engine_name
def find_engine_services_hashes(params)

    SystemUtils.debug_output("find_engine_services_hashes", params)

    engine_node = managed_engine_tree[params[:parent_engine]]
    #p get_all_leafs_service_hashes(engine_node)
     if engine_node == nil
       log_error_msg("Failed to find in managed service tree",params)
     end
    return get_all_leafs_service_hashes(engine_node)

  end

#@return all service_hashs marked persistant for :engine_name
  def get_engine_persistant_services(params) #params is :engine_name
    if params.has_key?(:parent_engine) == false
      params[:parent_engine] =  params[:engine_name]
    end
    services = find_engine_services(params)
    if services == nil
      log_error_msg("Failed to find engine in persistant service",params)
      return nil
    end
    leafs = Array.new

    services.children.each do |service|
      matches = get_matched_leafs(service,:persistant,true)
      SystemUtils.debug_output("matches",matches)
      leafs =  leafs.concat(matches)
    end
    return leafs
  end
  
  #Register the service_hash with the engine
  #return true if successful
  #returns false on error or duplicate
  #Needs overwrite flag
  #requires :parent_engine :type_path
  #@return boolean 
def add_to_managed_engines_tree(service_hash)

   if service_hash.has_key?(:parent_engine) == false || service_hash[:parent_engine] == nil
     log_error_msg("no_parent_engine_key",service_hash)
     return false
   end
   
   if managed_engine_tree[service_hash[:parent_engine] ] != nil
     engine_node = managed_engine_tree[ service_hash[:parent_engine] ]
   else
     engine_node = Tree::TreeNode.new(service_hash[:parent_engine],service_hash[:parent_engine] + " Engine Service Tree")
     managed_engine_tree << engine_node
   end

   service_type_node = create_type_path_node(engine_node,service_hash[:type_path])
   service_handle = get_service_handle(service_hash)
service_handle = service_hash[:service_handle]
   if service_type_node == nil
     log_error_msg("nil service type node",service_hash)
     return false
   end
   if service_handle == nil
     log_error_msg("Service hash has nil handle",service_hash)   
     return false
   end

   service_node = service_type_node[service_handle]

   if  service_node == nil
     service_node = Tree::TreeNode.new(service_handle,service_hash)
     service_type_node << service_node
   else
     log_error_msg("Node existed",service_handle)
     log_error_msg("With content",service_node.content)
     return false
   end

 end
 
 #Remove Service from engine service registry matching :parent_engine :type_path :service_handle
#@return boolean
 def remove_from_engine_registery service_hash
   
     service_node = find_engine_services(service_hash)
     if service_node != nil
       sucess = remove_tree_entry(service_node)
     end
     log_error_msg("Failed to find service node to remove service from engine registry ",service_hash)
     return false
 end
 
end