module Engines
  require_relative 'rset.rb'
  # engines Methods
  def find_engine_service_hash(params)
    rest_get('/v0/system_registry/engine/service/',{:params => params })
  end

  def find_engine_services_hashes(params)
    rest_get('/v0/system_registry/engine/services/',{:params => params })
  end

  def get_engine_nonpersistant_services(params)
    params[:persistant] = false
    rest_get('/v0/system_registry/engine/services/nonpersistant/',{:params => params })
  end

  def get_engine_persistant_services(params)
    params[:persistant] = true
    rest_get('/v0/system_registry/engine/services/persistant/',{:params => params })
  end

  def add_to_managed_engines_registry(service_hash)
    rest_post('/v0/system_registry/engine/services/add',service_hash )
  end

  def remove_from_managed_engines_registry(params)
    rest_delete('/v0/system_registry/engine/services/del',{:params => params })
  end

  def update_registered_managed_engine(params)
    rest_delete('/v0/system_registry/engine/services/update',{:params => params })
  end

  def managed_engines_registry
    rest_get('/v0/system_registry/engines/tree', nil)
  end

end