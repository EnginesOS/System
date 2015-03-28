#@Methods for handling orphaned persistant services
module OrphanedServices
  #@ remove from both the service registry and orphan registery
  #@param params { :type_path , :service_handle}
  def release_orphan(params)
    orphan = retrieve_orphan(params)
    if orphan == nil
      return false
    end

    remove_tree_entry(orphan)

    service = find_service_consumers(orphan.content)
    if service != nil
      remove_tree_entry(service)
    end

    save_tree
    return true
  end

  #@return [TreeNode] of Oprhaned Serivce that matches the supplied params
  #@param params { :type_path , :service_handle}
  #@return nil on no match
  def retrieve_orphan(params)

    types = get_all_engines_type_path_node(orphaned_services_tree,params[:type_path])
    if types == nil
      SystemUtils.log_error_msg("No Orphan Match",params)
      return nil
    end
    if types.is_a?(Array)
      types.each do |type|
        # p type.content

        if type[params[:service_handle]] != nil
          return type[params[:service_handle]]
        else
          SystemUtils.log_error_msg("params nil service_handle",params)
        end
      end
      return nil
    end
    return types[params[:service_handle]]

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
      content =  orphan.content
      content[:variables][:parent_engine]=params[:parent_engine]
      content[:parent_engine]=params[:parent_engine]
      return content
    else
      return nil
    end
  end

end