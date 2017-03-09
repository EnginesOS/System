module Subservices
  def services_subservices(params)
    # get 'subservices/consumers/:service_name/:engine_name/:service_handle'
    #   optional[:engine_name, :service_name, :service_handle]
    r ='sub_services/consumers'
    r += address_params(params, [:service_name,:engine_name,:service_handle])
    rest_get(r) 
  end
  
  def update_subservice(params)
    r = 'sub_service/consumers'
    r += full_address(params)
    #post 'sub_service/consumers' + address_params(params, [:service_name,:engine_name,:service_handle,:sub_handle])
    rest_post(r, {:api_vars => params })
  end

  def attach_subservice(params)
    r = 'sub_services/consumers'
    r += full_address(params)
    rest_post(r, {:api_vars => params })
    # post 'sub_services/consumers/:service_name/:engine_name/:service_handle/:sub_handle'
  end

  def remove_subservice(params)
    r = 'sub_services/consumers'
    r += full_address(params)
    # delete 'sub_services/consumers/:service_name/:engine_name/:service_handle/:sub_handle'
    rest_delete(r)
  end

  def attached_subservice(params)
    r = 'sub_service/consumers'
    r += full_address(params)
    rest_get(r)
    # get 'sub_service/consumers/:service_name/:engine_name/:service_handle/:sub_handle'
  end

  def subservice_provided(params)
    r = 'sub_service/providers'
    r += address_params(params, [:service_handle,:publisher_namespace,:type_path])
    rest_get(r)
    # get 'sub_service/providers/:service_handle/:publisher_namespace/*'
  end

  def subservices_provided(params)
    r = 'sub_services/providers'
    r += address_params(params, [:publisher_namespace,:type_path])
    rest_get(r)
    # get 'sub_services/providers/:publish_namespace/*'
  end
  def full_address(params)
      address_params(params, [:service_name,:engine_name,:service_handle,:sub_handle])
    end
end