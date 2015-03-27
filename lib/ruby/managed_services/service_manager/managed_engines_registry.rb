module ManagedEnginesRegistry
  
  def find_engine_services(params)
      engine_node = managed_engine_tree[params[:engine_name]]
  
      if params.has_key?(:type_path) && params[:type_path] != nil
        services = get_type_path_node(engine_node,params[:type_path]) #engine_node[params[:type_path]]
        if services != nil  && params.has_key?(:name) && params[:name] != nil
          service = services[params[:name]]
          return service
        else
          return services
        end
      else
        return engine_node
      end
    end
    
def find_engine_services_hashes(params)

    SystemUtils.debug_output("find_engine_services_hashes", params)

    engine_node = managed_engine_tree[params[:engine_name]]
    #p get_all_leafs_service_hashes(engine_node)
    return get_all_leafs_service_hashes(engine_node)

  end


  def get_engine_persistant_services(params) #params is :engine_name
    services = find_engine_services(params)
    if services == nil
      p :failed_to_find_engine_in_persistant_service
      p params
      return nil
    end
    leafs = Array.new

    services.children.each do |service|
      matches = get_matched_leafs(service,:persistant,true)
      SystemUtils.debug_output(" matches",matches)
      leafs =  leafs.concat(matches)
    end

    return leafs

  end
  
  
def add_to_managed_engines_tree(service_hash)

   if service_hash[:variables].has_key?(:parent_engine) == false || service_hash[:variables][:parent_engine] != nil
     p :no_parent_engine_key
     return false
   end
   if managed_engine_tree[service_hash[:variables][:parent_engine] ] != nil
     engine_node = managed_engine_tree[ service_hash[:variables][:parent_engine] ]
   else
     engine_node = Tree::TreeNode.new(service_hash[:variables][:parent_engine],service_hash[:variables][:parent_engine] + " Engine Service Tree")
     managed_engine_tree << engine_node
   end

   service_type_node = create_type_path_node(engine_node,service_hash[:type_path])

   service_label = get_service_label(service_hash)

   if service_type_node == nil
     p service_hash
     p :error_service_type_node
     return false
   end
   if service_label == nil
     p service_hash
     p :error_service_hash_has_nil_name
     return false
   end

   service_node = service_type_node[service_label]

   if  service_node == nil
     service_node = Tree::TreeNode.new(service_label,service_hash)
     service_type_node << service_node
   else
     p :Node_existed
     p service_label
   end

 end
end