module ServiceApiRestore
  @@import_timeout = 300
  def service_restore(service, stream, params)

    cmd = ['/home/services/restore.sh', params[:section].to_s]
    
    params = {container: service, command_line: cmd, log_error: true, data_stream: stream}

    SystemDebug.debug(SystemDebug.export_import, :import_service, params, service_params)
    begin
      result = {}
      Timeout.timeout(@@import_timeout) do
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
    result
  end
end