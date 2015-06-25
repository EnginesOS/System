#Module of methods to handle the Services Registry branch
module ServicesRegistry

  
  #@Boolean returns true | false if servcice hash is registered in service tree
  def service_is_registered?(service_hash)
    provider_node = service_provider_tree( service_hash[:publisher_namespace]) #managed_service_tree[service_hash[:publisher_namespace] ]
       if provider_node == false
         p :nil_provider_node
         return false
       end
    service_type_node = create_type_path_node(provider_node,service_hash[:type_path])
    if service_type_node == false
      p :nil_service_type_node
      return false 
    end
        engine_node  = service_type_node[service_hash[:parent_engine]]
        if engine_node == nil
          p :nil_engine_node
          return false
        end
 
  service_node  = engine_node[service_hash[:service_handle]]
         if service_node == nil
           p :nil_service_handle
           return false
         end
 
        p :service_hash_is_registered
   return true    
  end  

  #Add The service_hash to the services registry branch
  #creates the branch path as required
  #@service_hash :publisher_namespace . :type_path . :parent_engine
  #Wover writes
  def add_to_services_tree(service_hash)

    provider_node = service_provider_tree( service_hash[:publisher_namespace]) #managed_service_tree[service_hash[:publisher_namespace] ]
    if provider_node == false
      provider_node = Tree::TreeNode.new(service_hash[:publisher_namespace] ," Provider:" + service_hash[:publisher_namespace] + ":" + service_hash[:type_path]  )
      managed_service_tree << provider_node
    end

    service_type_node = create_type_path_node(provider_node,service_hash[:type_path])

    engine_node  = service_type_node[service_hash[:parent_engine]]
    if engine_node == nil
      engine_node = Tree::TreeNode.new(service_hash[:parent_engine],service_hash[:parent_engine])
      service_type_node << engine_node
    end

    service_node = engine_node[service_hash[:service_handle]]
    if service_node == nil
      SystemUtils.debug_output( :create_new_service_regstry_entry,service_hash)
      service_node = Tree::TreeNode.new(service_hash[:service_handle],service_hash)
      engine_node << service_node
    elsif service_hash[:persistant] == false
      SystemUtils.debug_output( :reattachexistsing_service_persistant_false,service_hash)
      service_node.content = service_hash
    else
      p :failed
      log_error_mesg("Service Node existed",service_hash[:service_handle])
      log_error_mesg("Cannot over write persistant service" + service_node.content.to_s + " with ",service_hash)
      #       service_node = Tree::TreeNode.new(service_hash[:parent_engine],service_hash)
      #       service_type_node << service_node

    end

    #FIXME need to handle updating service

    return true

  rescue Exception=>e
    puts e.message
    log_exception(e)
    return false
  end

  # @return an array of service_hashes in the Service registry that match the @type_path and @identifier
  def attached_services(type_path,identifier)
    retval = Array.new
    if managed_service_tree ==nil
      log_error_mesg("panic_no_managed_service_node", type_path.to_s + " " + identifier.to_s)
      return retval
    end
    services = get_type_path_node(managed_service_tree,type_path)

    if services == false
      return retval
    end
    service = services[identifier]
    if service == nil
      return  retval
    end
    service.each do |node|
      retval.push(node.content)
    end

  rescue Exception=>e
    puts e.message
    log_exception(e)

  end
#@returns a [Hash] matching

#@service_query_hash :publisher_namespace , :type_path , :service_handle
  def get_service_entry(service_query_hash)
      tree_node = find_service_consumers(service_query_hash)
        if tree_node == nil || tree_node == false
          return false                 
        end
        return tree_node.content
  end
  #@returns a [TreeNode] to the depth of the search
  #@service_query_hash :publisher_namespace
  #@service_query_hash :publisher_namespace , :type_path
  #@service_query_hash :publisher_namespace , :type_path , :service_handle
  def find_service_consumers(service_query_hash)

    if service_query_hash.has_key?(:publisher_namespace) == false || service_query_hash[:publisher_namespace]  == nil
      log_error_mesg("no_publisher_namespace",service_query_hash)
      return false
    end

    provider_tree = service_provider_tree(service_query_hash[:publisher_namespace])

    if service_query_hash.has_key?(:type_path) == false  || service_query_hash[:type_path] == nil
      log_error_mesg("find_service_consumers_no_type_path", service_query_hash)

      return provider_tree
    end

    service_path_tree = get_type_path_node(provider_tree,service_query_hash[:type_path])

    if service_path_tree ==  false
      log_error_mesg("Failed to find matching service path",service_query_hash)
      return false
    end

    if service_query_hash.has_key?(:parent_engine) == false || service_query_hash[:parent_engine]  == nil
      #log_error_mesg("find_service_consumers_no_parent_engine", service_query_hash)
      return  service_path_tree
    end

    services = service_path_tree[service_query_hash[:parent_engine]] 
      
    if  services == nil || services == false
      log_error_mesg("Failed to find matching parent_engine",service_query_hash)
      return false
    end

    if service_query_hash.has_key?(:service_handle) == false || service_query_hash[:service_handle]  == nil
      log_error_mesg("find_service_consumers_no_service_handle", service_query_hash)
      return  services
    end
SystemUtils.debug_output(:find_service_consumers_, service_query_hash[:service_handle])
 
    service = services[service_query_hash[:service_handle]]
    if service == nil
      log_error_mesg("failed to find match in services tree", service_query_hash)
      return false
    end
    return service

  end

  #remove the service matching the service_hash from the tree
  #@service_hash :publisher_namespace :type_path :service_handle
  def remove_from_services_registry(service_hash)

    if managed_service_tree !=nil
      service_node = find_service_consumers(service_hash)

      if service_node != false
        return remove_tree_entry(service_node)
      else
        log_error_mesg("Fail to find service for removal",service_hash)
      end
    end
    log_error_mesg("Fail to remove service" ,service_hash)
    return false
  end


#@return an [Array] of service_hashs of Active persistant services match @params [Hash]
#:path_type :publisher_namespace    
def get_active_persistant_services(params)
  
    
    leafs = Array.new
    services = find_service_consumers(params)
    if services != nil && services != false
      leafs = get_matched_leafs(services,:persistant,true)
    end   
    return leafs
 
end
  
end