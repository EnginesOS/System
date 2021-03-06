class EnginesCore
  def export_service(service_hash)
    #SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash)
    raise EnginesException.new(error_hash('missing parent_engine key', service_hash)) unless service_hash.key?(:parent_engine) == true
    ahash = retrieve_engine_service_hash(service_hash)
    raise EnginesException.new(error_hash("cannot import into share service", service_hash)) if ahash[:shared] == true
    if service_hash[:container_type] == 'app'
      engine = loadManagedEngine(service_hash[:parent_engine])
    else
      engine = loadManagedService(service_hash[:parent_engine])
    end
    engine.export_service_data(service_hash)
  end

  def import_service(params)
    raise EnginesException.new(error_hash("imported failed No service Connection", params)) unless params.key?(:service_connection)
    service_hash =  params[:service_connection]
    raise EnginesException.new(error_hash("imported failed No service Connection", params)) unless service_hash.is_a?(Hash)
    symbolize_keys(service_hash)
    ahash = retrieve_engine_service_hash(service_hash)
    raise EnginesException.new(error_hash("cannot import into share service", params)) if ahash[:shared] == true
  #  SystemDebug.debug(SystemDebug.export_import, :export_service_hahs, service_hash)
    if service_hash[:container_type] == 'app'
      engine = loadManagedEngine(service_hash[:parent_engine])
    else
      engine = loadManagedService(service_hash[:parent_engine])
    end
    engine.import_service_data(params)
  end

end