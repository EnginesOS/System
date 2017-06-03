module Orphans
  def rollback_orphaned_service(params)
    r =  'services/orphan/'
    r += address_params(params, full_path)
    rest_post(r, {:api_vars => params})
  end

  def retrieve_orphan(params)
    r = 'services/orphan/'
    r += address_params(params, full_path)
    rest_get(r)
  end

  def orphaned_services(params)
    r = 'services/orphans/'
    r += address_params(params, [:publisher_namespace, :type_path])
    rest_get(r)
  end

  def orphanate_service(params)
    r = 'services/orphans/add/'
    r += address_params(params, [:parent_engine, :service_handle, :publisher_namespace, :type_path])
    rest_post(r, {:api_vars => params})
  end

  def release_orphan(params)
    r = 'services/orphans/del/'
    r += address_params(params, [:parent_engine, :service_handle, :publisher_namespace, :type_path])
    rest_delete(r)
  end

  def orphaned_services_registry
    rest_get('services/orphans/tree', nil)
  end

  def full_path
    @fp ||= [:parent_engine, :service_handle, :publisher_namespace, :type_path]
  end
end