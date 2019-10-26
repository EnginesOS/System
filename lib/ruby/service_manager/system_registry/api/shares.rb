module Shares
  def shared_services_registry
    get('shares/tree', nil)
  end

  def remove_from_shared_services_registry(shared_service)
    r = 'shares/del' + address_params(shared_service, [:service_owner, :parent_engine, :service_handle, :publisher_namespace, :type_path])
    delete(r)
  end

  def add_share_to_managed_engines_registry(shared_service)
    r = 'shares/add' + address_params(shared_service, [:service_owner, :parent_engine, :service_handle, :publisher_namespace, :type_path])
    post(r, shared_service)
  end
end