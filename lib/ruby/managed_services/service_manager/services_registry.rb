module ServicesRegistry
  
  
  def add_to_services_tree(service_hash)
 
     provider_node = service_provider_tree( service_hash[:publisher_namespace]) #managed_service_tree[service_hash[:publisher_namespace] ]
     if provider_node == nil
       provider_node = Tree::TreeNode.new(service_hash[:publisher_namespace] ," Provider:" + service_hash[:publisher_namespace] + ":" + service_hash[:type_path]  )
       managed_service_tree << provider_node
     end
 
     service_type_node = create_type_path_node(provider_node,service_hash[:type_path])
 
     service_node = service_type_node[service_hash[:variables][:parent_engine]]
     if service_node == nil
       service_node = Tree::TreeNode.new(service_hash[:variables][:parent_engine],service_hash)
       service_type_node << service_node
     end
     #FIXME need to handle updating service
 
   rescue Exception=>e
     puts e.message
     SystemUtils.log_exception(e)
 
   end
   
   
def attached_services(service_type,identifier)
   retval = Array.new
   if managed_service_tree ==nil
     p :panic_no_managed_service_node
     return retval
   end
   services =    get_type_path_node(managed_service_tree,service_type)

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
def find_service_consumers(service_query_hash)

  if service_query_hash.has_key?(:publisher_namespace) == false || service_query_hash[:publisher_namespace]  == nil
    p :no_publisher_namespace
    return false
  end

  provider_tree = service_provider_tree(service_query_hash[:publisher_namespace])

  if service_query_hash.has_key?(:type_path) == false  || service_query_hash[:type_path] == nil
    p :find_service_consumers_no_type_path
    p service_query_hash
    # p provider_tree
    return provider_tree
  end

  service_path_tree = get_type_path_node(provider_tree,service_query_hash[:type_path])
  #provider_tree[service_hash[:type_path]]

  if service_path_tree == nil
    return false
  end

  if service_query_hash.has_key?(:variables) == false || service_query_hash[:variables]  == nil
    p :find_service_consumers_no_variables
    p service_query_hash
    return  service_path_tree
  end

  if  service_path_tree[service_query_hash[:variables][:name]] == nil
    return false
  end

  #p :find_service_consumers
  #                p service_path_tree[service_query_hash[:variables][:name]]
  #
  return service_path_tree[service_query_hash[:variables][:name]]

end


def remove_service service_hash

    query_hash=Hash.new()

    query_hash[:engine_name] = service_hash[:variables][:parent_engine]
    query_hash[:type_path] = service_hash[:type_path]

    service_node = find_engine_services(query_hash)
    if service_node != nil
      sucess = remove_tree_entry(service_node)
    end

    if managed_service_tree !=nil
      service_node = find_service_consumers(service_hash)

      if service_node != nil
        return remove_tree_entry(service_node)

      end

    end

    SystemUtils.debug_output("FAILED_TO_REMOVE_SERVICE",service_hash)

    @last_error ="No service record found for " + service_hash[:variables][:parent_engine].to_s
    @last_error += " service_type:" +  service_hash[:type_path].to_s
    @last_error  += " Provider " + service_hash[:publisher_namespace].to_s
    @last_error += " Name " + service_hash[:variables][:name].to_s
    return false

  rescue Exception=>e
    if service_hash != nil
      p service_hash
    end
    SystemUtils.log_exception(e)
    return false
  end

end