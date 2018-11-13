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

  def export_service_data(container, service_hash, stream)
    cmd_dir = SystemConfig.EngineServiceBackupScriptsRoot + '/'
    cmd = cmd_dir + '/backup.sh'
    raise EnginesException.new(error_hash("failed to export service not running " + container.container_name.to_s)) unless container.is_running?
  params = {container: container, command_line: [cmd], log_error: true, service_variables: service_hash} #data: service_hash.to_json}
    params[:ostream] =  stream unless stream.nil?
    export(container, params)
  end

  def export_data(container, stream)

    SystemDebug.debug(SystemDebug.export_import, :export_service, container.container_name)
    cmd_dir = SystemConfig.ServiceBackupScriptsRoot + '/'
    raise EnginesException.new(error_hash("failed to export service not running " + container.container_name.to_s)) unless container.is_running?
    cmd = cmd_dir + '/backup.sh'
    params = {container: container, command_line: [cmd], log_error: true}
    params[:stream] =  stream unless stream.nil?
    SystemDebug.debug(SystemDebug.export_import, :export_service, cmd)
    export(container, params)
  end

  def export(container, params)
    begin

      result = {result:  0}
      thr = Thread.new { result = @engines_core.exec_in_container(params) }
      thr[:name] = 'export:' + params.to_s
      Timeout.timeout(@@export_timeout) do
        thr.join
        SystemDebug.debug(SystemDebug.export_import, :export_service, container.container_name, 'result code =', result[:result])
        result
      end
    rescue Timeout::Error
      thr.kill unless thr.nil?

      result[:result] = -1;
      result[:stderr] = 'Export Timeout on Running Action:' + cmd.to_s + ':' + result[:stderr].to_s
      #raise EnginesException.new(error_hash('Export Timeout on Running Action ', cmd))

    end
    if result[:result] == 0
      result #[stdout]
    else
      raise EnginesException.new(error_hash("failed to export " + @result.to_s, container.container_name))
    end
  end
end