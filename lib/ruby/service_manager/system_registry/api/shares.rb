module Shares
  def shares_registry_tree
    rest_get('shares/tree', nil)
  end

  def remove_from_shares_registry(shared_service)
    rest_post('shares/del', shared_service )
  end

  def add_share_to_managed_engines_registry(shared_service)
    add_to_managed_engines_registry(shared_service)
    rest_post('shares/add', shared_service )
  end
end