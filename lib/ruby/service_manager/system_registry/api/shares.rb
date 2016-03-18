module Shares

    require_relative 'rset.rb'

  
    def shares_registry
      rest_get('/v0/system_registry/shares/tree', nil)
    end
 
    def add_share_to_managed_engines_registry(shared_service)
      add_to_managed_engines_registry(shared_service)
  r =    rest_post('/v0/system_registry/shares/add',shared_service )
  p :add_share_to_managed_engines_registry
  p r
      
    end
end