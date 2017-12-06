module ServiceApiRestore
  @@import_timeout = 300
  def service_restore(service, stream, params)
   return unless service.is_running?
    cmd = ['/home/engines/scripts/backup/restore.sh',params[:replace].to_s, params[:section].to_s] #, params[:section].to_s]
    
    params = {container: service, command_line: cmd, log_error: true, data_stream: stream}
    STDERR.puts(' stram ' + stream.inspect)
    SystemDebug.debug(SystemDebug.export_import, :import_service, params)
    begin
      result = {}
      Timeout.timeout(@@import_timeout) do
        thr = Thread.new { result = @engines_core.exec_in_container(params) }
        thr.join
        thr[:name] = 'restore:' + service.container_name.to_s
        SystemDebug.debug(SystemDebug.export_import, :import_service,'result ', result.to_s)
        if result[:result] == 0
          true
        else
          raise EnginesException.new(error_hash("failed to import " + service.container_name.to_s, result))
        end
      end
    rescue Timeout::Error
      thr.kill
      raise EnginesException.new(error_hash('Import Timeout on Running Action ', cmd))
    end
    result
  end
end