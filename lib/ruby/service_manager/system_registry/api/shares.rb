module Shares
  def shared_services_registry
    rest_get('shares/tree', nil)
  end

  def remove_from_shared_services_registry(shared_service)
    rest_post('shares/del', shared_service )
  end

  def add_share_to_managed_engines_registry(shared_service)
    add_to_managed_engines_registry(shared_service)
    rest_post('shares/add', shared_service )
  end
end