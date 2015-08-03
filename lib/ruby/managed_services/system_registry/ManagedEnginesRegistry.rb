class ManagedEnginesRegistry  < SubRegistry  
  
  
  def find_engine_services(params)
    if params == nil
      log_error_mesg("find_engine_services passed nil params",params)
      return false
    end

    engines_type_tree = managed_engines_type_registry(params)
    if engines_type_tree.is_a?(Tree::TreeNode) == false
      return false
    end
    
    engine_node =   engines_type_tree[params[:parent_engine]]
    if engine_node.is_a?(Tree::TreeNode) == false
      return false
    end
    SystemUtils.debug_output( :find_engine_services_with_params, params)
    if params.has_key?(:type_path) && params[:type_path] != nil
      services = get_type_path_node(engine_node,params[:type_path]) #engine_node[params[:type_path]]
      if services.is_a?(Tree::TreeNode) == true  && params.has_key?(:service_handle) && params[:service_handle] != nil
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
    if params.has_key?(:engine_name)
      params[:parent_engine] = params[:engine_name]
    end
    SystemUtils.debug_output("find_engine_services_hashes", params)

    engine_node = managed_engines_type_registry(params)[params[:parent_engine]]
    #p get_all_leafs_service_hashes(engine_node)
    if engine_node.is_a?(Tree::TreeNode) == false
      log_error_mesg("Failed to find in managed service tree",params)    
    end
    
    if  params.has_key?(:type_path)
      engine_node = engine_node[:type_path]
    end
    
  if engine_node.is_a?(Tree::TreeNode) == false
     log_error_mesg("Failed to find in managed service tree",params)    
   end
   
      if params.has_key?(:persistant) 
        if params[:persistant] == true
          return get_matched_leafs(engine_node,:persistant,true)
        else 
          return get_matched_leafs(engine_node,:persistant,false)
       end
      end
    return get_all_leafs_service_hashes(engine_node)
  end


  #@return [Array] of all service_hashs marked persistance [boolean] for :engine_name
  def get_engine_persistance_services(params,persistance) #params is :engine_name
     
    leafs = Array.new

    if params.has_key?(:parent_engine) == false
      params[:parent_engine] =  params[:engine_name]
    end
    services = find_engine_services(params)
    if services.is_a?(Tree::TreeNode) == false
      log_error_mesg("Failed to find engine in persistant service",params)
      return leafs
    end

    services.children.each do |service|
      SystemUtils.debug_output(:finding_match_for, service.content)
      matches = get_matched_leafs(service,:persistant,persistance)
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
  #overwrites
  def add_to_managed_engines_registry(service_hash)

    if service_hash.has_key?(:parent_engine) == false || service_hash[:parent_engine] == nil
      log_error_mesg("no_parent_engine_key",service_hash)
      return false
    end
    engines_type_tree = managed_engines_type_registry(service_hash)
    if engines_type_tree.is_a?(Tree::TreeNode) == false 
      log_error_mesg("no_type tree ",service_hash)
        return false 
    end
    if engines_type_tree[service_hash[:parent_engine]] != nil
      engine_node = engines_type_tree[ service_hash[:parent_engine] ]
    else
      engine_node = Tree::TreeNode.new(service_hash[:parent_engine],service_hash[:parent_engine] + " Engine Service Tree")
    managed_engines_type_registry(service_hash) << engine_node
    end

    service_type_node = create_type_path_node(engine_node,service_hash[:type_path])
    service_handle = get_service_handle(service_hash)
    service_handle = service_hash[:service_handle]
    if service_type_node.is_a?(Tree::TreeNode) == false 
      log_error_mesg("no service type node",service_hash)
      return false
    end
    if service_handle == nil
      log_error_mesg("Service hash has nil handle",service_hash)
      return false
    end

    service_node = service_type_node[service_handle]

    if  service_node == nil
      service_node = Tree::TreeNode.new(service_handle,service_hash)
      service_type_node << service_node
    elsif service_hash[:persistant] == false
      service_node.content = service_hash
    else
      log_error_mesg("Engine Node existed",service_handle)
      log_error_mesg("Cannot over write persistant service" + service_node.content.to_s + " with ",service_hash)
      #     service_node = Tree::TreeNode.new(service_handle,service_hash)
      #     service_type_node << service_node
      #   service_node.content = service_hash
      return false
    end

    return true
  end
#@return the service_handle from the service_hash
# for backward compat (to be changed)
def get_service_handle(params)

  if  params.has_key?(:service_handle) && params[:service_handle] != nil
    return params[:service_handle]
  else
    log_error_mesg("no :service_handle",params)

    return nil
  end
end
  #@return the appropriate tree under managedservices trees either engine or service
  def managed_engines_type_registry(site_hash)
    if @registry.is_a?(Tree::TreeNode) == false
      return false
    end
    if site_hash.has_key?(:container_type) == false
      log_error_mesg("Site hash missing :container_type",site_hash)
      #return false
    end
    if site_hash[:container_type] == "service"
      if @registry["Service"] == nil
        @registry << Tree::TreeNode.new("Service"," Managed Services register")
      end
      return @registry["Service"]
    elsif site_hash[:container_type] == "system"
      if @registry["System"] == nil
              @registry << Tree::TreeNode.new("System"," System Services register")
            end
            return @registry["System"]
    else
      if @registry["Application"] == nil
        @registry << Tree::TreeNode.new("Application"," Managed Application register")
      end
      return @registry["Application"]
    end
  end

  #Remove Service from engine service registry matching :parent_engine :type_path :service_handle
  #@return boolean
  def remove_from_engine_registry service_hash

    service_node = find_engine_services(service_hash)
    if service_node.is_a?(Tree::TreeNode) == true
      return remove_tree_entry(service_node)
    end
    log_error_mesg("Failed to find service node to remove service from engine registry ",service_hash)
    return false
  end

#end
end