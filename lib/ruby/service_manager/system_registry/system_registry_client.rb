class SystemRegistryClient < ErrorsApi

  def initialize(core_api)
    @core_api = core_api
  end

  def api_shutdown
    
  end
  
  
# Configurations methods 
  
  def get_service_configurations_hashes(config_hash)
    rest_get('/system_registry/service/configurations/',{:params => config_hash })
    end
  
    def get_service_configuration(config_hash)
      rest_get('/system_registry/services/configuration/',{:params => config_hash })
      end
      
    def update_service_configuration(config_hash)
      rest_put('/system_registry/services/configuration/',config_hash )
    end
    
    def rm_service_configuration(config_hash)
      rest_delete('/system_registry/services/configurations/',{:params => config_hash } )
    end
    
    def add_service_configuration(config_hash)
      rest_post('/system_registry/services/configurations/',config_hash )
      end
      
    def service_configurations_registry
      rest_get('/system_registry/services/configurations/tree', nil)
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
      rest_get('/system_registry/services/orphan/',{:params => params } )
    end
  
    def get_orphaned_services(params)
      rest_get('/system_registry/services/orphans/',{:params => params } )
    end
  
    def orphanate_service(service_query_hash)
      rest_post('/system_registry/services/',params )
    end

  def release_orphan(params)
    rest_delete('/system_registry/services/orphans/',{:params => params } )
  end
  
  
  # engines Methods 

  def find_engine_service_hash(params)
    p :find_engine_service_has
    STDERR.puts params.to_s
    
   r = rest_get('/system_registry/engine/service/',{:params => params })
     p r
     r
  end

  def find_engine_services_hashes(params)
    STDERR.puts  ':find_engine_services_hashes'
   
    STDERR.puts params.to_s
    r =  rest_get('/system_registry/engine/services/',{:params => params })
    STDERR.puts r.to +  ' -<rest'
    r
  end

  def get_engine_nonpersistant_services(params)
    STDERR.puts ':get_engine_nonpersistant_services'
    STDERR.puts params.to_s
    

    r =  rest_get('/system_registry/engine/services/nonpersistant/',{:params => params })
    p r
    r
  end

  def get_engine_persistant_services(params)
    p :get_engine_persistant_services

    STDERR.puts params.to_s
    r =  rest_get('/system_registry/engine/services/persistant/',{:params => params })
    p r
    r
  end

  def add_to_managed_engines_registry(service_hash)
    rest_post('/system_registry/engine/services/',service_hash )
  end

  def remove_from_managed_engines_registry(params)
    rest_delete('/system_registry/engine/services/',{:params => params })
   end


  
  # Services Methods

  def all_engines_registered_to(service_type)
    STDERR.puts service_type.to_s
    rest_get('/system_registry/service/registered/engines/',{:params => service_type })
  end 
  
  
  def find_service_consumers(service_query_hash)
    rest_get('/system_registry/service/consumers/',{:params => service_query_hash })
  end

  def update_attached_service(service_hash)
    rest_put('/system_registry/service/', service_hash)
  end

  def add_to_services_registry(service_hash)
    rest_post('/system_registry/services/',service_hash )
  end

  def remove_from_services_registry(service_hash)
    rest_delete('/system_registry/services/',{:params => service_hash })
  end

  def service_is_registered?(service_hash)
    rest_get('/system_registry/service/is_registered',{:params => service_hash })
  end

  def get_registered_against_service(params)
    rest_get('/system_registry/service/registered/',{:params => params })
  end
  

  def get_service_entry(service_hash)
    rest_get('/system_registry/service/',{:params => params })
  end

  
  # @return an Array of Strings of the Provider names in use
  # returns nil on failure
  def list_providers_in_use
    rest_get('/system_registry/services/providers/in_use/',{:params => params })
  end

  # @ Return complete system registry tree
  def system_registry_tree
    rest_get('/system_registry/tree', nil)
  end


  def orphaned_services_registry
    rest_get('/system_registry/services/orphans/tree', nil)
  end

  def services_registry
    rest_get('/system_registry/services/tree', nil)
  end

  def managed_engines_registry
    rest_get('/system_registry/engines/tree', nil)
  end

  private
  def parse_rest_response(r)
      return false if r.code > 399
    return true if r.to_s   == '' ||  r.to_s   == 'true'
    return false if r.to_s  == 'false' 
     res = JSON.parse(r, :create_additions => true)     
     return symbolize_keys(res) if res.is_a?(Hash)
     return res 
   rescue
     p "Failed to parse rest response _" + r.to_s + "_"
       return false
  end
  
  def base_url
    'http://' + @core_api.get_registry_ip + ':4567'
  end
  
  require 'rest-client'
  
  def rest_get(path,params)
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
