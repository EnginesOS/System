#@Methods for handling orphaned persistant services
module OrphanedServices
  #@ remove from both the service registry and orphan registery
  #@param params { :type_path , :service_handle}
  def release_orphan(params)
    orphan = retrieve_orphan(params)
    if orphan == nil
      log_error_mesg("No Orphan found to release",params)
      return false
    end

   if remove_tree_entry(orphan)

    return save_tree
   end
   return false
  
  end
  #Saves the service_hash in the orphaned service registry 
  #@return result 
  def save_as_orphan(service_hash)
    if service_hash.has_key?(:service_handle) && service_hash.has_key?(:type_path)    
    type_node = create_type_path_node(orphaned_services_tree,service_hash[:type_path])     
    #INSERT Enginename here
      type_node << Tree::TreeNode.new(service_hash[:service_handle],service_hash)     
      return true
    end
    return false
  end
  #@return [TreeNode] of Oprhaned Serivce that matches the supplied params
  #@param params { :type_path , :service_handle}
  #@return nil on no match
  def retrieve_orphan(params)

    p :orpahns_retr_start
    p params[:type_path]
      type_path = params[:type_path]
    types = get_type_path_node(orphaned_services_tree,type_path)
    if types == nil
      log_error_mesg("No Orphan Matching type_path",params)
      return false
    end
    if  types.is_a?(Array)
      types.each do |type|
        # p type.content
        if type == nil
          log_error_mesg(" nil type in ",types)
            next
        end
         if type[params[:service_handle]] != nil
          return type[params[:service_handle]]
        else
          log_error_mesg("params nil service_handle",params)
        end
  end
      log_error_mesg("No Matching Orphan",params)
      return false
else
    orphan =  types[params[:service_handle]]
      if orphan == nil
        log_error_mesg("No Matching Orphan",params)
        return false
      else
        return orphan
      end
  end
end

  #@return  orphaned_services_tree
  #@wrapper for the gui
  def get_orphaned_services_tree
    return  orphaned_services_tree
  end

  #@ Assign a new parent to an orphan
  #@return new service_hash
  def reparent_orphan(params)
    orphan = retrieve_orphan(params)
    if orphan !=nil
      content = orphan.content
      content[:variables][:parent_engine]=params[:parent_engine]
      content[:parent_engine]=params[:parent_engine]
      return content
    else
      log_error_mesg("No orphan found to reparent",params)
      return nil
    end

  end
  
#@return an [Array] of service_hashs of Orphaned persistant services match @params [Hash]
   #:path_type :publisher_namespace      
   def get_orphaned_services(params)
     leafs = Array.new
     orphans = find_orphan_consumers(params)
     if orphans != nil && orphans != false
       leafs = get_matched_leafs(orphans,:persistant,true)
     end   
     return leafs
   end
   
#@returns a [TreeNode] to the depth of the search
 #@service_query_hash :publisher_namespace
 #@service_query_hash :publisher_namespace , :type_path
 #@service_query_hash :publisher_namespace , :type_path , :service_handle
 def find_orphan_consumers(service_query_hash)

   if service_query_hash.has_key?(:publisher_namespace) == false || service_query_hash[:publisher_namespace]  == nil
     log_error_mesg("no_publisher_namespace",service_query_hash)
     return false
   end

   provider_tree = orphaned_services_tree[service_query_hash[:publisher_namespace]]

   if service_query_hash.has_key?(:type_path) == false  || service_query_hash[:type_path] == nil
     log_error_mesg("find_service_consumers_no_type_path", service_query_hash)

     return provider_tree
   end

   service_path_tree = get_type_path_node(provider_tree,service_query_hash[:type_path])

   if service_path_tree == nil
     log_error_mesg("Failed to orphan find matching service path",service_query_hash)
     return false
   end
   
   return  service_path_tree
 end
      
end