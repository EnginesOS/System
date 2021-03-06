class SystemRegistryClient
  def subservices_registry
    rest_get('sub_services/tree', nil)
  end
  def services_subservices(params)
    r ='sub_services/consumers'
    r += address_params(params, [:service_name, :engine_name, :service_handle])
    rest_get(r)
  end

  def update_subservice(params)
    r = 'sub_service/consumers'
    r += full_address(params)
    post(r, {:api_vars => params })
  end

  def attach_subservice(params)
    r = 'sub_services/consumers'
    r += full_address(params)
    post(r, {:api_vars => params })
  end

  def remove_subservice(params)
    r = 'sub_services/consumers'
    r += full_address(params)
    delete(r)
  end

  def attached_subservice(params)
    r = 'sub_service/consumers'
    r += full_address(params)
    rest_get(r)
  end

  def subservice_provided(params)
    r = 'sub_service/providers'
    r += address_params(params, [:service_handle, :publisher_namespace, :type_path])
    rest_get(r)
  end

  def subservices_provided(params)
    r = 'sub_services/providers'
  #  /v0/system_registry/sub_services/consumers/:service_name/:engine_name/:service_handle
    r += address_params(params, [:service_name, :engine_name,:service_handle])
    rest_get(r)
  end

  def full_address(params)
    address_params(params, [:service_name, :engine_name, :service_handle, :sub_handle])
  end
end