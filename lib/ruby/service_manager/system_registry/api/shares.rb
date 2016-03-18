module Shares

    require_relative 'rset.rb'

  
    def shares_registry
      rest_get('/v0/system_registry/shares/tree', nil)
    end
 
    def add_share_to_managed_engines_registry(shared_service)
      return false unless add_to_managed_engines_registry(shared_service)
      rest_post('/v0/shares_registry/add',shared_service )
      
    end
end