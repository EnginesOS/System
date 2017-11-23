module EngineApiExportImport
  require "base64"
  #FixMe shoudl be based on size and guesstimaed connection speed etc
  @@export_timeout = 220

  def export_service_data(container, service_hash, stream = nil)
    raise EnginesException.new(warn_hash("Cannot export as single service", service_hash)) unless SoftwareServiceDefinition.is_consumer_exportable?(service_hash)     
    SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash)
    cmd_dir = SystemConfig.BackupScriptsRoot + '/' + service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + '/' + service_hash[:service_handle] + '/'

    cmd = cmd_dir + '/backup.sh'
    SystemDebug.debug(SystemDebug.export_import, :export_service, cmd)
    begin
      result = {}
      params = {container: container, command_line: [cmd], log_error: true }
      params[:stream] =  stream unless stream.nil?
      Timeout.timeout(@@export_timeout) do
        thr = Thread.new { result = @engines_core.exec_in_container(params) }
        #SystemUtils.execute_command(cmd, true) }
        thr[:name] = 'export:' + params.to_s
        thr.join
        SystemDebug.debug(SystemDebug.export_import, :export_service,service_hash,'result code =' ,result[:result],params)
        if result[:result] == 0
          result[:stdout]
        else
          raise EnginesException.new(error_hash("failed to export " + result.to_s ,service_hash))
        end
      end
    rescue Timeout::Error
      thr.kill
      raise EnginesException.new(error_hash('Export Timeout on Running Action ', params.to_s,cmd))
    end
  end

  def import_service_data(container, service_params, stream = nil)    
    service_hash = service_params[:service_connection]
    raise EnginesException.new(warn_hash("Cannot import as single service", service_hash)) unless SoftwareServiceDefinition.is_consumer_exportable?(service_hash)
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
    SystemDebug.debug(SystemDebug.export_import, :import_service, params, service_params)
    begin
      result = {}
      Timeout.timeout(@@export_timeout) do
        thr = Thread.new { result = @engines_core.exec_in_container(params) }
        thr.join
        thr[:name] = 'import:' + params.to_s
        SystemDebug.debug(SystemDebug.export_import, :import_service,'result ' ,result.to_s)
        if result[:result] == 0
          true
        else
          raise EnginesException.new(error_hash("failed to import ",service_params,params, result))
        end
      end
    rescue Timeout::Error
      thr.kill
      raise EnginesException.new(error_hash('Import Timeout on Running Action ', cmd))
    end
  end
end