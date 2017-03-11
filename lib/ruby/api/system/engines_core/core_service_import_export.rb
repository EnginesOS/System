module CoreServiceImportExport
  def export_service(service_hash)
    SystemDebug.debug(SystemDebug.export_import, :export_service,service_hash)
    #    return false unless service_hash.key?(:persistent)
    #    return false unless service_hash[:persistent] == true
    return log_error_mesg('missing parent_engine key',service_hash) unless service_hash.key?(:parent_engine) == true
    ahash = service_manager.find_engine_service_hash(service_hash)
    return log_error_mesg("cannot import into share service",service_hash) if ahash[:shared] == true
    if service_hash[:container_type] == 'container'
      engine = loadManagedEngine(service_hash[:parent_engine])
    else
      engine = loadManagedService(service_hash[:parent_engine])
    end
    return engine if engine.is_a?(EnginesError)
    engine.export_service_data(service_hash)
  rescue StandardError => e
    log_exception(e,'export service',service_hash)
  end

  def import_service(params)
   
    return log_error_mesg("imported failed No service Connection",params) unless params.key?(:service_connection)
    
    service_hash =  params[:service_connection]
    return log_error_mesg("imported failed No service Connection",params) unless service_hash.is_a?(Hash)
   SystemUtils.symbolize_keys(service_hash)
    ahash = service_manager.find_engine_service_hash(service_hash)
    return log_error_mesg("cannot import into share service",params) if ahash[:shared] == true
    SystemDebug.debug(SystemDebug.export_import, :export_service_hahs, service_hash)
    if service_hash[:container_type] == 'container'
      engine = loadManagedEngine(service_hash[:parent_engine])
    else
      engine = loadManagedService(service_hash[:parent_engine])
    end
    return engine  if engine.is_a?(EnginesError)
      engine.import_service_data(params)

  rescue StandardError => e
    log_exception(e,'import service',params)
  end

end