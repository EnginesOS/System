module ServiceApiRestore
  @@import_timeout = 300
  def service_restore(service, stream, params)
    STDERR.puts(' stram ' + stream.inspect)
   return unless service.is_running?
    cmd = [SystemConfig.BackupScriptsRoot + '/restore.sh',params[:replace].to_s, params[:section].to_s] #, params[:section].to_s]
    
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
  
 def export_data(container, stream)

  #    unless SoftwareServiceDefinition.is_consumer_exportable?(service_hash)
  #      stream.close unless stream.nil?
  #      raise EnginesException.new(warning_hash("Cannot export as single service", service_hash))
  #    end 
     
      SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash)
      cmd_dir = SystemConfig.BackupScriptsRoot + '/' 
  
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
end