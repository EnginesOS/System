module Engines
  # engines Methods
  def find_engine_service_hash(params)
    SystemDebug.debug(SystemDebug.services,'sm find_engine_service_hash  ', params)
    r = 'engine/service'
    r += address_params(params,[:container_type,:parent_engine,:service_handle,:type_path] )
    rest_get(r)
  end

  def find_engine_services_hashes(params)
    r = 'engine/services'
    r += address_params(params,[:container_type,:parent_engine,:type_path] )
    rest_get(r)
  end

  def get_engine_nonpersistent_services(params)
    params[:persistent] = false
    r = 'engine/services/nonpersistent'
    r += address_params(params,[:container_type,:parent_engine])
    rest_get(r)
  end

  def get_engine_persistent_services(params)
    params[:persistent] = true
    r =  'engine/services/persistent'
    r += address_params(params,[:container_type,:parent_engine])
    rest_get(r)
  end

  def add_to_managed_engines_registry(service_hash)
    SystemDebug.debug(SystemDebug.services,'sm add_to_managed_engines_registry ', service_hash)
    r = 'engine/services/add'
    r += address_params(service_hash, full_path)
    rest_post(r,{:api_vars => service_hash} )
  end

  def remove_from_managed_engine(params)
    params[:container_type] = 'container' unless params.key?(:container_type)
    STDERR.puts('PARAMAS FOR DELEparams' + params.to_s)
    r = 'engine/services/del'
    r += address_params(params, full_path)
    rest_delete(r)
  end

  def update_registered_managed_engine(params)
    r = 'engine/services/update'
    r += address_params(params,full_path)
    rest_post(r,{:api_vars => params })
  end

  def managed_engines_registry
    rest_get('engines/tree', nil)
  end

  private

  def full_path
    @fullpath ||= [:container_type, :parent_engine, :service_handle, :publisher_namespace, :type_path]
  end

end