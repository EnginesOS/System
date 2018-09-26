module EngineApiExportImport
  require "base64"
  #FixMe shoudl be based on size and guesstimaed connection speed etc
  @@export_timeout = 220

  def export_service_data(container, service_hash, stream = nil)
    #    unless SoftwareServiceDefinition.is_consumer_exportable?(service_hash)
    #      stream.close unless stream.nil?
    #      raise EnginesException.new(warning_hash("Cannot export as single service", service_hash))
    #    end

    SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash)
    cmd_dir = SystemConfig.BackupScriptsRoot + '/' + service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + '/' + service_hash[:service_handle] + '/'

    cmd = cmd_dir + '/backup.sh'
    SystemDebug.debug(SystemDebug.export_import, :export_service, cmd)

    @result = {result: 0}
    params = {container: container, command_line: [cmd], log_error: true}
    params[:stream] =  stream unless stream.nil?
    thr = Thread.new { @result = @engines_core.exec_in_container(params) }
    thr[:name] = 'export:' + params.to_s
    begin
      Timeout.timeout(@@export_timeout) do
        thr.join
      end
     SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash,'result code =' ,@result[:result])
    rescue Timeout::Error
      thr.kill
      raise EnginesException.new(error_hash('Export Timeout on Running Action ', service_hash))
    end
    if @result[:result] == 0
      @result #[stdout]
    else
      raise EnginesException.new(error_hash("failed to export " + @result.to_s ,service_hash))
    end

  end

  def import_service_data(container, service_params, stream = nil)
    service_hash = service_params[:service_connection]
    unless SoftwareServiceDefinition.is_consumer_exportable?(service_hash)
      stream.close unless stream.nil?
      raise EnginesException.new(warning_hash("Cannot import as single service", service_hash))
    end
    SystemDebug.debug(SystemDebug.export_import, :import_service, service_params,service_params[:import_method])
    cmd_dir = SystemConfig.BackupScriptsRoot + '/' + service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + '/' + service_hash[:service_handle] + '/'
    if service_params[:import_method] == :replace
      cmd = cmd_dir + '/replace.sh'
    else
      cmd = cmd_dir + '/restore.sh'
    end
    params = {container: container, command_line: [cmd], log_error: true }
    unless stream.nil?
      params[:data_stream] = stream
    else
      params[:data] = Base64.decode64(service_params[:data])
    end
    SystemDebug.debug(SystemDebug.export_import, :import_service,  service_params)
    begin
      result = {}
      thr = Thread.new { result = @engines_core.exec_in_container(params) }
      thr[:name] = 'import:' + params.to_s
      to = Timeout.timeout(@@export_timeout) do
        thr.join        
      end
      result = params[:result]
      SystemDebug.debug(SystemDebug.export_import, :import_service,'result ' ,result.to_s)
      if result[:result] == 0
        true
      else
        raise EnginesException.new(error_hash("failed to import ",
        {service_params: service_params,
          result: result}))
      end
    rescue Timeout::Error
      thr.kill
      raise EnginesException.new(error_hash('Import Timeout on Running Action ', cmd))
    end
  rescue  StandardError => e
    if e.is_a?(EnginesException)
      raise e
    else
      raise EnginesException.new(error_hash('Import Error on Running Action ', container.container_name, service_params))
    end
  end

end