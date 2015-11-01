class SystemRegistryClient < ErrorsApi

  def initialize(core_api)
    @core_api = core_api
  end

  def api_shutdown
    
  end
  

  
  require_relative 'rset.rb'
  
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
      
      
  def all_engines_registered_to(service_type)
      rest_get('/v0/system_registry/service/registered/engines/',{:params => service_type })
    end 
    
    
    def find_service_consumers(service_query_hash)
      rest_get('/v0/system_registry/service/consumers/',{:params => service_query_hash }) 
    end
  
    def update_attached_service(service_hash)
      rest_put('/v0/system_registry/service/update', service_hash)
    end
  
    def add_to_services_registry(service_hash)
      rest_post('/v0/system_registry/services/add',service_hash )
    end
  
    def remove_from_services_registry(service_hash)
      rest_delete('/v0/system_registry/services/del',{:params => service_hash })
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
    
  def services_registry
     rest_get('/v0/system_registry/services/tree', nil)
   end

  
  # @ Return complete system registry tree
   def system_registry_tree
     
     rest_get('/v0/system_registry/tree', nil)
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
   
   
  def orphaned_services_registry
    rest_get('/v0/system_registry/services/orphans/tree', nil)
  end

  
  
  def find_engine_service_hash(params)
   rest_get('/v0/system_registry/engine/service/',{:params => params })
  end
 
  def find_engine_services_hashes(params)
    rest_get('/v0/system_registry/engine/services/',{:params => params })
  end
 
  def get_engine_nonpersistant_services(params)
    params[:persistant] = false
   rest_get('/v0/system_registry/engine/services/nonpersistant/',{:params => params })  
  end
 
  def get_engine_persistant_services(params)
    params[:persistant] = true
    rest_get('/v0/system_registry/engine/services/persistant/',{:params => params })
  end
 
  def add_to_managed_engines_registry(service_hash)
    rest_post('/v0/system_registry/engine/services/',service_hash )
  end
 
  def remove_from_managed_engines_registry(params)
    rest_delete('/v0/system_registry/engine/services/del',{:params => params })
   end
 
  def update_registered_managed_engine(params)
      rest_delete('/v0/system_registry/engine/services/update',{:params => params })
     end
     
 
 def managed_engines_registry
   rest_get('/v0/system_registry/engines/tree', nil)
 end

  
  
  
   
    
end
