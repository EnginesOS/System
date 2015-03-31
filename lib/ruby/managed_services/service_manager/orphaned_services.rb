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

    remove_tree_entry(orphan)

#    service = find_service_consumers(orphan.content)
#    if service != nil
#      remove_tree_entry(service)
#    end
 
    return true
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
      log_error_mesg("No oprhan found to reparent",params)
      return nil
    end
  end

end