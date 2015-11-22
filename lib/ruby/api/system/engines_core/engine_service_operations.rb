module EngineServiceOperations
  require_relative 'service_manager_access.rb'
  def engine_persistant_services(container_name)
    params = {}
    params[:parent_engine] = container_name
    params[:persistant] = true
    params[:container_type] ='container'
    p :engine_persistant_services
    p params
    return check_sm_result(service_manager.get_engine_persistant_services(params))
  rescue StandardError => e
    log_exception(e)
  end

  def engine_attached_services(container_name)
    params = {}
    params[:parent_engine] = container_name
    params[:container_type] = 'container'
    return service_manager.find_engine_services_hashes(params)
  rescue StandardError => e
    log_exception(e)
  end

  def  service_is_registered?(service_hash)
    return false unless check_service_hash(service_hash)
    check_sm_result(service_manager.service_is_registered?(service_hash))
  end

  def get_engine_persistant_services(service_hash)
    return false unless check_engine_hash(service_hash)
    check_sm_result(service_manager.get_engine_persistant_services(service_hash))
  end

  def find_engine_services(service_query)
    return false unless check_engine_hash(service_query)
    check_sm_result(service_manager.find_engine_services_hashes(service_query))
    #return sm.find_engine_services(params)
  end

end