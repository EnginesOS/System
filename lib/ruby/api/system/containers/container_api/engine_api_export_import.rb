class ContainerApi
  require "base64"
  #FixMe shoudl be based on size and guesstimaed connection speed etc
  @@export_timeout = 600

  def export_service_data(container, service_hash, stream = nil)
    #    unless SoftwareServiceDefinition.is_consumer_exportable?(service_hash)
    #      stream.close unless stream.nil?
    #      raise EnginesException.new(warning_hash("Cannot export as single service", service_hash))
    #    end
   
    service_hash = core.retrieve_service_hash(service_hash)
    # SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash)
    cmd_dir = "#{SystemConfig.BackupScriptsRoot}/#{service_hash[:publisher_namespace]}/#{service_hash[:type_path]}/#{service_hash[:service_handle]}/"

    cmd = "#{cmd_dir}/backup.sh"
    #  SystemDebug.debug(SystemDebug.export_import, :export_service, cmd)
    result = {result: 0}
    params = {
      container: container,
      command_line: [cmd],
      log_error: true,
      timeout: @@export_timeout,
      service_variables: service_hash}
    params[:stdout_stream] = stream unless stream.nil?

    thr = Thread.new { result = core.exec_in_container(params) }
    thr[:name] = "export:#{params}"
    begin
      Timeout.timeout(@@export_timeout + 5) do
        thr.join
      end
      #  SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash,'result code =' ,result[:result])
      result
    rescue Timeout::Error
      thr.kill
      eresult = {}
      #  raise EnginesException.new(error_hash('Export Timeout on Running Action ', service_hash))
      eresult[:result] = -1;
      eresult[:stderr] = "Export Timeout on Running Action:#{cmd}:#{result[:stderr]}"
      eresult
    rescue StandardError => e
      SystemUtils.log_exception(e , 'export_service_data:' + service_hash.to_s)
      thr.exit unless thr.nil?
    end

  end

  def import_service_data(container, service_params, stream = nil)
    service_hash = service_params[:service_connection]
    unless SoftwareServiceDefinition.is_consumer_exportable?(service_hash)
      stream.close unless stream.nil?
      raise EnginesException.new(warning_hash("Cannot import as single service", service_hash))
    end
    service_hash = core.retrieve_service_hash(service_hash)
    #  SystemDebug.debug(SystemDebug.export_import, :import_service, service_params,service_params[:import_method])
    cmd_dir = "#{SystemConfig.BackupScriptsRoot}/#{service_hash[:publisher_namespace]}/#{service_hash[:type_path]}/#{service_hash[:service_handle]}/"
    if service_params[:import_method] == :replace
      cmd = "#{cmd_dir}/replace.sh"
    else
    cmd = "#{cmd_dir}/restore.sh"
    end
    #  env =   service_variables_to_env(service_hash)
    # env = service_hash.merge!(service_hash[:variables])
    # env.delete(:variables)
    ##  params = {container: container, command_line: [cmd, "'" + service_hash.to_json + "'" ], log_error: true }
    params = {container: container, command_line: [cmd], log_error: true, service_variables: service_hash }
    #params = {container: container, command_line: [cmd, "'" + service_hash.to_json + "'" ], log_error: true }
    unless stream.nil?
      params[:stdin_stream] = stream
    else
      params[:data] = Base64.decode64(service_params[:data])
    end
    #  SystemDebug.debug(SystemDebug.export_import, :import_service,  service_params)
    begin
      result = {}
      thr = Thread.new { result = core.exec_in_container(params) }
      thr[:name] = "import:#{params}"
      to = Timeout.timeout(@@export_timeout) do
        thr.join
      end

    rescue Timeout::Error
      thr.kill
      eresult = {}
      eresult[:result] = -1;
      eresult[:stderr] = 'Import Timeout on Running Action:' + cmd.to_s + ':' + result[:stderr].to_s
      result = eresult
    rescue StandardError => e
      SystemUtils.log_exception(e , 'import_service_data:' + params)
      thr.exit unless thr.nil?
    end
  end

end
