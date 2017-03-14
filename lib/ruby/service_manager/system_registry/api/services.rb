module Services
  # Services Methods
  def all_engines_registered_to(service_type)
    SystemDebug.debug(SystemDebug.registry,'  All registered to  ',service_type.to_s)
    rest_get('service/registered/engines/' + service_type )
  end

  def find_service_consumers(service_query_hash)
    r = 'service/consumers'
    r += address_params(service_query_hash,[:publisher_namespace,:type_path])
    rest_get(r)
  end

  def update_attached_service(params)
    r = 'service/update'
    r += address_params(params,[:parent_engine,:service_handle,:publisher_namespace,:type_path])
    rest_post(r, {:api_vars => params })
  end

  def add_to_services_registry(service_hash)
    SystemDebug.debug(SystemDebug.services,'sm add_to_servicess_registry ', service_hash)
    r = 'services/add'
    r += address_params(service_hash,[:parent_engine,:service_handle,:publisher_namespace,:type_path])
    rest_post( r,  {:api_vars => service_hash} )
  end

  def remove_from_services_registry(params)
    r = 'services/del'
    r +=  address_params(params,[:parent_engine,:service_handle,:publisher_namespace,:type_path])
    rest_delete(r)
  end

  def service_is_registered?(service_hash)
    r = 'service/is_registered' + address_params(service_hash,[:parent_engine,:service_handle,:publisher_namespace,:type_path])
    rest_get(r)
  end

  def get_registered_against_service(params)
    r = 'service/registered' + address_params(params,[:publisher_namespace,:type_path])
    rest_get(r)
  end

  def get_service_entry(service_hash)
    r = 'service' + address_params(service_hash,[:parent_engine,:service_handle,:publisher_namespace,:type_path])
    rest_get(r)
  end

  # @return an Array of Strings of the Provider names in use
  # returns nil on failure
  def list_providers_in_use
    rest_get('services/providers/in_use/',nil)
  end

  def clear_service_from_registry(service_hash)
    r = 'services/clear'
    r+= address_params(service_hash,[:container_type,:parent_engine,:persistence])
    rest_delete(r)
  end

  def services_registry
    rest_get('services/tree', nil)
  end
end