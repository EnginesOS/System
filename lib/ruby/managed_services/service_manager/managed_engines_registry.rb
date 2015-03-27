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

    leafs = Array.new

    services.children.each do |service|
      matches = get_matched_leafs(service,:persistant,true)
      SystemUtils.debug_output(" matches",matches)
      leafs =  leafs.concat(matches)
    end

    return leafs

  end
end