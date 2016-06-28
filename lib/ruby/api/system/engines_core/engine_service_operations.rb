module EngineServiceOperations
  require_relative 'service_manager_access.rb'
  def engine_persistent_services(container_name)
    params = {}
    params[:parent_engine] = container_name
    params[:persistent] = true
    params[:container_type] ='container'
    SystemDebug.debug(SystemDebug.services, :engine_persistent_services, params)
    return service_manager.get_engine_persistent_services(params)
  rescue StandardError => e
    log_exception(e,container_name)
  end
  
  def service_persistent_services(service_name)
    params = {}
    params[:parent_engine] = service_name
    params[:persistent] = true
    params[:container_type] ='service'
    SystemDebug.debug(SystemDebug.services,  :engine_persistent_services, params)
    return service_manager.get_engine_persistent_services(params)
  rescue StandardError => e
    log_exception(e,service_name)
  end
  
  def service_attached_services(service_name)
     params = {}
     params[:parent_engine] = service_name
     params[:container_type] = 'service'
     return service_manager.find_engine_services_hashes(params)
   rescue StandardError => e
     log_exception(e,service_name)
   end
  
  def engine_attached_services(container_name)
    params = {}
    params[:parent_engine] = container_name
    params[:container_type] = 'container'
    return service_manager.find_engine_services_hashes(params)
  rescue StandardError => e
    log_exception(e,container_name)
  end

  def  service_is_registered?(service_hash)
    r = ''
    return r unless  ( r = check_service_hash(service_hash))
    service_manager.service_is_registered?(service_hash)
    rescue StandardError => e
      log_exception(e,service_hash)
  end

  def get_engine_persistent_services(service_hash)
    r = ''
    return r unless (r = check_engine_hash(service_hash))
    service_manager.get_engine_persistent_services(service_hash)
    rescue StandardError => e
      log_exception(e,service_hash)
  end

  def find_engine_services(service_query)
    r = ''
    return r unless  (r = check_engine_hash(service_query))
    service_manager.find_engine_services_hashes(service_query)
    rescue StandardError => e
      log_exception(e,service_query)
    #return sm.find_engine_services(params)
  end
  
  def attach_existing_service_to_engine(params)
    r = ''
     SystemDebug.debug(SystemDebug.services,'core attach existing service', params)
    return r unless (r = check_engine_hash(params))
    service_manager.attach_existing_service_to_engine(params)
    rescue StandardError => e
      log_exception(e,params)
 
   end

end