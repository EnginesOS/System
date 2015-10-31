class SystemRegistryClient < ErrorsApi

  def initialize(core_api)
    @core_api = core_api
  end

  def api_shutdown
    
  end
  
  
# Configurations methods 
  
  def get_service_configurations_hashes(config_hash)
    rest_get('/v0/system_registry/service/configurations/',{:params => config_hash })
    end
  
    def get_service_configuration(config_hash)
      rest_get('/v0/system_registry/services/configuration/',{:params => config_hash })
      end
      
    def update_service_configuration(config_hash)
      rest_put('/v0/system_registry/services/configuration/',config_hash )
    end
    
    def rm_service_configuration(config_hash)
      rest_delete('/v0/system_registry/services/configurations/',{:params => config_hash } )
    end
    
    def add_service_configuration(config_hash)
      rest_post('/v0/system_registry/services/configurations/',config_hash )
      end
      
    def service_configurations_registry
      rest_get('/v0/system_registry/services/configurations/tree', nil)
    end
   
  # orphans Methods
    
#  def reparent_orphan(params)
#      t_st_result(send_request('reparent_orphan', params))
#    end
#  
#    def rebirth_orphan(params)
#      t_st_result(send_request('rebirth_orphan', params))
#    end
  
    def retrieve_orphan(params)
      rest_get('/v0/system_registry/services/orphan/',{:params => params } )
    end
  
    def get_orphaned_services(params)
      rest_get('/v0/system_registry/services/orphans/',{:params => params } )
    end
  
    def orphanate_service(service_query_hash)
      rest_post('/v0/system_registry/services/',service_query_hash )
    end

  def release_orphan(params)
    rest_delete('/v0/system_registry/services/orphans/',{:params => params } )
  end
  
  
  # engines Methods 

  def find_engine_service_hash(params)
   rest_get('/v0/system_registry/engine/service/',{:params => params })
  end

  def find_engine_services_hashes(params)
    rest_get('/v0/system_registry/engine/services/',{:params => params })
  end

  def get_engine_nonpersistant_services(params)
   rest_get('/v0/system_registry/engine/services/nonpersistant/',{:params => params })  
  end

  def get_engine_persistant_services(params)
    rest_get('/v0/system_registry/engine/services/persistant/',{:params => params })
  end

  def add_to_managed_engines_registry(service_hash)
    rest_post('/v0/system_registry/engine/services/',service_hash )
  end

  def remove_from_managed_engines_registry(params)
    rest_delete('/v0/system_registry/engine/services/',{:params => params })
   end


  
  # Services Methods

  def all_engines_registered_to(service_type)
    rest_get('/v0/system_registry/service/registered/engines/',{:params => service_type })
  end 
  
  
  def find_service_consumers(service_query_hash)
    rest_get('/v0/system_registry/service/consumers/',{:params => service_query_hash }) # was all_engines_registered_to
  end

  def update_attached_service(service_hash)
    rest_put('/v0/system_registry/service/', service_hash)
  end

  def add_to_services_registry(service_hash)
    rest_post('/v0/system_registry/services/',service_hash )
  end

  def remove_from_services_registry(service_hash)
    rest_delete('/v0/system_registry/services/',{:params => service_hash })
  end

  def service_is_registered?(service_hash)
    rest_get('/v0/system_registry/service/is_registered',{:params => service_hash })
  end

  def get_registered_against_service(params)
    rest_get('/v0/system_registry/service/registered/',{:params => params })
  end
  

  def get_service_entry(service_hash)
    rest_get('/v0/system_registry/service/',{:params => service_hash })
  end

  
  # @return an Array of Strings of the Provider names in use
  # returns nil on failure
  def list_providers_in_use
    rest_get('/v0/system_registry/services/providers/in_use/',nil)
  end

  # @ Return complete system registry tree
  def system_registry_tree
    
    rest_get('/v0/system_registry/tree', nil)
  end


  def orphaned_services_registry
    rest_get('/v0/system_registry/services/orphans/tree', nil)
  end

  def services_registry
    rest_get('/v0/system_registry/services/tree', nil)
  end

  def managed_engines_registry
    rest_get('/v0/system_registry/engines/tree', nil)
  end

  private
  def parse_rest_response(r)
      return false if r.code > 399
    return true if r.to_s   == '' ||  r.to_s   == 'true'
    return false if r.to_s  == 'false' 
     res = JSON.parse(r, :create_additions => true)       
     STDERR.puts("res "  + deal_with_jason(res).to_s)  
     return deal_with_jason(res)
   rescue
     p "Failed to parse rest response _" + res.to_s + "_"
       return false
  end
  
  def deal_with_jason(res)
    return symbolize_keys(res) if res.is_a?(Hash)
    return symbolize_keys_array_members(res) if res.is_a?(Array)
    return symbolize_tree(res) if res.is_a?(Tree::TreeNode)
    return boolean_if_true_false_str(res) if res.is_a?(String)
    return res
  end
  
  def boolean_if_true_false_str(r)
                   if  r == 'true'
                     return true
                   elsif r == 'false'
                    return false
                   end
        return r     
  end  
  
  def symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
      new_key = case key
      when String then key.to_sym
      else key
      end
      new_value = case value
      when Hash then symbolize_keys(value)
      when Array then
        newval = []
        value.each do |array_val|        
            array_val = symbolize_keys(array_val) if array_val.is_a?(Hash)
            array_val =  boolean_if_true_false_str(r) if array_val.is_a?(String)
          newval.push(array_val)
        end
        newval
        when String then
        boolean_if_true_false_str(value)
      else value
      end
      result[new_key] = new_value
      result
    }
  end
        
  def symbolize_keys_array_members(array)
     return array if array.count == 0
    return array unless array[0].is_a?(Hash)
    retval = []
    i = 0
    array.each do |hash|
      retval[i] = array[i]
      next if hash.nil?
      next unless hash.is_a?(Hash)       
      retval[i] = symbolize_keys(hash)
      i += 1
    end
  return retval
   end
   
   def symbolize_tree(tree)     
     nodes = tree.children
      nodes.each do |node|
        node.content = symbolize_keys(node.content) if node.content.is_a?(Hash)
        symbolize_tree(node)
      end
      return tree
   end
     
  def base_url
    'http://' + @core_api.get_registry_ip + ':4567'
  end
  
  require 'rest-client'
  
  def rest_get(path,params)
    STDERR.puts('Path:' + path.to_s + ' Params:' + params.to_s)
    parse_rest_response(RestClient.get(base_url + path, params)) 
  end
  
  def rest_post(path,params)
    parse_rest_response(RestClient.post(base_url + path, params))
  end
  
  def rest_put(path,params)
    parse_rest_response(RestClient.put(base_url + path, params))
  end
  
  def rest_delete(path,params)
    parse_rest_response(RestClient.delete(base_url + path, params))
  end
  
  
    
end
