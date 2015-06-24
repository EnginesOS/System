module ServiceConfigurations
  
  #@ return an [Array] of Service Configuration [Hash]es of all the service configurations for [String] service_name
  def get_service_configurations(service_name)    
    
    service_configurations = service_configurations_tree[service_name]
    
    if service_configurations.is_a?(Tree::TreeNode)
      return service_configurations     
    end
    return false
  end

  def get_service_configurations_hashes(service_name)
    configurations = get_service_configurations(service_name)
    if  configurations == false
      p "no service configurations for " + service_name.to_s
      return Array.new
    else
      leafs = get_all_leafs_service_hashes(configurations)
      p "leafs are " +  leafs.to_s
      return leafs
  end
  
  end
  
  #@ return a service_configuration_hash addressed by :service_name :configuration_name
  
  def get_service_configuration(service_configuration_hash)

    service_configurations = get_service_configurations(service_configuration_hash[:service_name])  
    if service_configurations == false
      return false
    end
    
    if service_configuration_hash.has_key?(:configurator_name) == false     
            return get_all_leafs_service_hashes(service_configurations)
    end
    
      service_configuration = service_configurations[service_configuration_hash[:configurator_name]]
      if service_configuration.is_a?(Tree::TreeNode)
        return service_configuration.content
    end
    return false
  end
  
  def add_service_configuration(service_configuration_hash)
    configurations = get_service_configurations(service_configuration_hash[:service_name])
    if configurations == false
      configurations = Tree::TreeNode.new(service_configuration_hash[:service_name] ," Configurations for :" + service_configuration_hash[:service_name]  )
      service_configurations_tree << configurations
    elsif !configurations[service_configuration_hash[:configurator_name]]
      p :service_configuration_hash_exists
      p service_configuration_hash.to_s
      return false 
    end
      configuration = Tree::TreeNode.new(service_configuration_hash[:configurator_name],service_configuration_hash)
      configurations << configuration
p "add " + service_configuration_hash.to_s
      save_tree
    
  end
  
  def rm_service_configuration(service_configuration_hash)
    service_configurations = get_service_configurations(service_configuration_hash[:service_name])  
        if service_configurations == false
          p :serivce_configurations_not_found
          return false
        end
        
        if service_configuration_hash.has_key?(:configurator_name) == false
          p :no_configuration_name     
                return false
        end
        
          service_configuration = service_configurations[service_configuration_hash[:configurator_name]]
          if service_configuration.is_a?(Tree::TreeNode)
            remove_tree_entry(service_configuration)
            save_tree
           return true
        end
        return false
  end
  
  def update_service_configuration(service_configuration_hash)
    service_configurations = get_service_configurations(service_configuration_hash[:service_name])  
            if service_configurations == false
              p :serivce_configurations_not_found
              return add_service_configuration(service_configuration_hash)
              #return false
            end
            
            if service_configuration_hash.has_key?(:configurator_name) == false
              p :no_configuration_name     
              return  add_service_configuration(service_configuration_hash)
              
            end
            
              service_configuration = service_configurations[service_configuration_hash[:configurator_name]]
              if service_configuration.is_a?(Tree::TreeNode)
                service_configuration.content = service_configuration_hash
                p "saved " + service_configuration_hash
                save_tree
               return true
            end
            return false
    end
  
end