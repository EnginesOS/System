module Shares

 # require_relative 'xcon_rset.rb'
  def shares_registry_tree
    rest_get('/v0/system_registry/shares/tree', nil)
  end

  def remove_from_shares_registry(shared_service)
  
    r = rest_post('/v0/system_registry/shares/del',shared_service )
  end

  def add_share_to_managed_engines_registry(shared_service)
    add_to_managed_engines_registry(shared_service)
    r =    rest_post('/v0/system_registry/shares/add',shared_service )

  end
end