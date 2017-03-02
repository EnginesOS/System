module Orphans
  def rollback_orphaned_service(params)
    rest_post('services/orphans/return/'+ pe_sh_st_path(params), {:api_vars => params})
  end

  def retrieve_orphan(params)
    rest_get('services/orphan/' + pe_sh_st_path(params))
  end

  def get_orphaned_services(params)
    rest_get('services/orphans/' + st_path(params))
  end

  def orphanate_service(params)
    rest_post('services/orphans/add/' + pe_sh_st_path(params), {:api_vars => params})
  end

  def release_orphan(params)
    rest_delete('services/orphans/del/' + pe_sh_st_path(params) )
  end

  def orphaned_services_registry
    rest_get('services/orphans/tree', nil)
  end
end