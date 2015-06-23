module ServiceConfigurations
  
  #@ return an [Array] of Service Configuration [Hash]es of all the service configurations for [String] service_name
  def get_service_configurations(service_name)
    service_configurations_tree.has_key?(service_name)
    service_configuration = service_configurations_tree[service_name]
    if service_configuration.is_a?(TreeNode)
      return service_configuration[:configurations]
    end
  end
  
  #@ return a service_configuration_hash addressed by :service_name :configuration_name
  
  def get_service_configuration(service_configuration_hash)

    service_configurations = service_configurations_tree[service_name]
          if service_configurations.is_a(TreeNode) == false
             return false
          end

    
    if service_configuration_hash.has_key?(:configuration_name) == false     
            return get_all_leafs_service_hashes(service_configurations)
    end
      service_configuration_hash = service_configurations[service_configuration_hash[:configuration_name]]
      if service_configuration_hash.is_a?(Hash)
        return service_configuration_hash
    end
    return false
  end
  
  def add_service_configuration(service_configuration_hash)
    
  end
  
  def rm_service_configuration(service_configuration_hash)
  end
  
  def update_service_configuration(service_configuration_hash)
    end
  
end