module Orphans

 # require_relative 'xcon_rset.rb'

  # orphans Methods
  #  def reparent_orphan(params)
  #      t_st_result(send_request('reparent_orphan', params))
  #    end
  #
  #    def rebirth_orphan(params)
  #      t_st_result(send_request('rebirth_orphan', params))
  #    end
  def rollback_orphaned_service(params)
    rest_post('/v0/system_registry/services/orphans/return/'+ pe_sh_st_path(params), params)
  end

  def retrieve_orphan(params)
    rest_get('/v0/system_registry/services/orphan/' + pe_sh_st_path(params))
  end

  def get_orphaned_services(params)
    rest_get('/v0/system_registry/services/orphans/' + st_path(params))
  end

  def orphanate_service(params)
    rest_post('/v0/system_registry/services/orphans/add/' + pe_sh_st_path(params), params)
  end

  def release_orphan(params)
    rest_delete('/v0/system_registry/services/orphans/del/' + pe_sh_st_path(params) )
  end

  def orphaned_services_registry
    rest_get('/v0/system_registry/services/orphans/tree', nil)
  end
end