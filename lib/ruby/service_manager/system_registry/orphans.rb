require_relative 'rset.rb'

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
