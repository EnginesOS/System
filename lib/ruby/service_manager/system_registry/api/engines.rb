module Engines
  # engines Methods
  def retrieve_engine_service_hash(params)
    r = 'engine/service'
    r += address_params(params, [:container_type, :parent_engine, :service_handle, :type_path])  
    rest_get(r)
  end

  def find_engine_services_hashes(params)
    
  STDERR.puts("\n\n find_engine_services_hashes" + params.to_s)
    r = 'engine/services'
    r += address_params(params, [:container_type, :parent_engine, :type_path])
    rest_get(r)
  end

  def get_engine_nonpersistent_services(params)
    params[:persistent] = false
    r = 'engine/services/nonpersistent'
    r += address_params(params, [:container_type, :parent_engine])
    rest_get(r)
  end

  def get_engine_persistent_services(params)
    params[:persistent] = true
    r =  'engine/services/persistent'
    r += address_params(params, [:container_type, :parent_engine])
    rest_get(r)
  end

  def add_to_managed_engines_registry(service_hash)
    r = 'engine/services/add'
    r += address_params(service_hash, [:container_type, :parent_engine, :service_handle, :publisher_namespace, :type_path])
    post(r,{:api_vars => service_hash} )
  end

  def remove_from_managed_engine(params)
    params[:container_type] = 'app' unless params.key?(:container_type)
    r = 'engine/services/del'
    r += address_params(params, [:container_type, :parent_engine, :service_handle, :publisher_namespace, :type_path])
    delete(r)
  end

  def update_registered_managed_engine(params)
    r = 'engine/service/update'
    r += address_params(params, [:container_type, :parent_engine, :service_handle, :publisher_namespace, :type_path])
    post(r,{:api_vars => params })
  end

  def managed_engines_registry
    rest_get('engines/tree', nil)
  end

  private

  def full_path
    [:container_type, :parent_engine, :service_handle, :publisher_namespace, :type_path]
  end

end