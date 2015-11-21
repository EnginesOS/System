module Registry

  require_relative 'rset.rb'
  # @ Return complete system registry tree
  def system_registry_tree

    rest_get('/v0/system_registry/tree', nil)
  end

end