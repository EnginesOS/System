module CoreServiceImportExport
  def export_service(service_hash)
    SystemDebug.debug(SystemDebug.export_import, :export_service,service_hash)
    #    return false unless service_hash.key?(:persistent)
    #    return false unless service_hash[:persistent] == true
    return false unless service_hash.key?(:parent_engine) == true

    if service_hash[:container_type] == 'container'
      engine = loadManagedEngine(service_hash[:parent_engine])
    else
      engine = loadManagedService(service_hash[:parent_engine])

    end

    engine.export_service_data(service_hash)
  rescue StandardError => e
    log_exception(e,'export service',service_hash)
  end

  def import_service(params)
    SystemDebug.debug(SystemDebug.export_import, :export_service, params)
    if params[:container_type] == 'container'
      engine = loadManagedEngine(params[:parent_engine])
    else
      engine = loadManagedService(params[:parent_engine])
    end
    return log_error_mesg("imported failed to load",params[:parent_engine] ,  params[:container_type]  ) if engine.nil?
     return engine.import_service_data(params)


    return false
  rescue StandardError => e
    log_exception(e,'import service',params)
  end

end