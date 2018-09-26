module ServiceApiRestore
  @@import_timeout = 300
  @@export_timeout = 300
  def service_restore(service, stream, params)

    raise EnginesException.new(error_hash("failed to import service not running " + service.container_name.to_s)) unless service.is_running?
    cmd = [SystemConfig.ServiceBackupScriptsRoot + '/restore.sh',params[:replace].to_s, params[:section].to_s] #, params[:section].to_s]
    params = {container: service, command_line: cmd, log_error: true, data_stream: stream}
    SystemDebug.debug(SystemDebug.export_import, :import_service)
    # STDERR.puts('STREAM' + stream.inspect)
    result = {}

    thr = Thread.new { result = @engines_core.exec_in_container(params) }
    thr[:name] = 'restore:' + service.container_name.to_s
    begin
      Timeout.timeout(@@import_timeout) do
        thr.join      
      end
      SystemDebug.debug(SystemDebug.export_import, :import_service,'result ', result.to_s)
    rescue Timeout::Error
      thr.kill
      raise EnginesException.new(error_hash('Import Timeout on Running Action ', cmd))
    end
    if result[:result] == 0
      true
    else
      raise EnginesException.new(error_hash("failed to import " + service.container_name.to_s, result))
    end
    result
  end

  def export_data(container, stream)

    #    unless SoftwareServiceDefinition.is_consumer_exportable?(service_hash)
    #      stream.close unless stream.nil?
    #      raise EnginesException.new(warning_hash("Cannot export as single service", service_hash))
    #    end

    SystemDebug.debug(SystemDebug.export_import, :export_service, container.container_name)
    cmd_dir = SystemConfig.ServiceBackupScriptsRoot + '/'
    raise EnginesException.new(error_hash("failed to export service not running " + container.container_name.to_s)) unless container.is_running?
    cmd = cmd_dir + '/backup.sh'
    SystemDebug.debug(SystemDebug.export_import, :export_service, cmd)
    result = {result:  0}
    begin
      params = {container: container, command_line: [cmd], log_error: true}
      params[:stream] =  stream unless stream.nil?
      thr = Thread.new { result = @engines_core.exec_in_container(params) }
   thr[:name] = 'export:' + params.to_s
      Timeout.timeout(@@export_timeout) do
        thr.join
        SystemDebug.debug(SystemDebug.export_import, :export_service, container.container_name, 'result code =', result[:result])
        result
      end
    rescue Timeout::Error
      thr.kill unless thr.nil?
      raise EnginesException.new(error_hash('Export Timeout on Running Action ', cmd))

    end
      
  end
end