#Module of methods to handle the Services Registry branch
module ServicesRegistry
  
  #Add The service_hash to the services registry branch
  #creates the branch path as required :publisher_namespace . :type_path . :parent_engine
  #Will not over write
  
  def add_to_services_tree(service_hash)

    provider_node = service_provider_tree( service_hash[:publisher_namespace]) #managed_service_tree[service_hash[:publisher_namespace] ]
    if provider_node == nil
      provider_node = Tree::TreeNode.new(service_hash[:publisher_namespace] ," Provider:" + service_hash[:publisher_namespace] + ":" + service_hash[:type_path]  )
      managed_service_tree << provider_node
    end

    service_type_node = create_type_path_node(provider_node,service_hash[:type_path])

    service_node = service_type_node[service_hash[:parent_engine]]
    if service_node == nil
      service_node = Tree::TreeNode.new(service_hash[:parent_engine],service_hash)
      service_type_node << service_node
    end
    #FIXME need to handle updating service
    
    return true
    
  rescue Exception=>e
    puts e.message
    SystemUtils.log_exception(e)
    return false
  end

  # @return an array of service_hashes in the Service registry that match the @type_path and @indentifier  
  def attached_services(type_path,identifier)
    retval = Array.new
    if managed_service_tree ==nil
      SystemUtils.log_error_msg("panic_no_managed_service_node", type_path.to_s + " " + identifier.to_s)
      return retval
    end
    services = get_type_path_node(managed_service_tree,type_path)

    if services == nil
      return retval
    end
    service = services[identifier]
    if service == nil
      return  retval
    end
    service.each do |node|
      retval.push(node.content)
      #      p node
    end

  rescue Exception=>e
    puts e.message
    SystemUtils.log_exception(e)

  end

  #@returns a [TreeNode] to the depth of the search
  #@service_query_hash :publisher_namespace
#@service_query_hash :publisher_namespace , :type_path
#@service_query_hash :publisher_namespace , :type_path , :service_handle
  def find_service_consumers(service_query_hash)

    if service_query_hash.has_key?(:publisher_namespace) == false || service_query_hash[:publisher_namespace]  == nil
      SystemUtils.log_error_msg("no_publisher_namespace",service_query_hash)
      return false
    end

    provider_tree = service_provider_tree(service_query_hash[:publisher_namespace])

    if service_query_hash.has_key?(:type_path) == false  || service_query_hash[:type_path] == nil
      SystemUtils.log_error_msg("find_service_consumers_no_type_path", service_query_hash)
      
      return provider_tree
    end

    service_path_tree = get_type_path_node(provider_tree,service_query_hash[:type_path])
    #provider_tree[service_hash[:type_path]]

    if service_path_tree == nil
      return false
    end

    if service_query_hash.has_key?(:variables) == false || service_query_hash[:variables]  == nil
      SystemUtils.log_error_msg("find_service_consumers_no_variables", service_query_hash)
      return  service_path_tree
    end

    if  service_path_tree[service_query_hash[:service_handle]] == nil
      return false
    end

    #p :find_service_consumers
    #                p service_path_tree[service_query_hash[:variables][:name]]
    #
    return service_path_tree[service_query_hash[:service_handle]]

  end
  def remove_from_services_registry(service_hash)
  
if managed_service_tree !=nil
   service_node = find_service_consumers(service_hash)

   if service_node != nil
     return remove_tree_entry(service_node)
   end
end
   return false
end

end