module EngineApiExportImport
  def export_service(service_hash)
    SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash)
    cmd_dir = SystemConfig.BackupScriptsRoot + '/' + service[:publisher_namespace] + '/' + service[:type_path] + '/' + service[:service_handle] + '/'
    cmd = 'docker exec  ' + service[:parent_engine] + ' ' + cmd_dir + '/backup.sh ' 
   
    SystemDebug.debug(SystemDebug.export_import, :export_service, cmd)
        begin
          result = {}
          Timeout.timeout(@@action_timeout) do
            thr = Thread.new { result = SystemUtils.execute_command(cmd) }
            thr.join
            SystemDebug.debug(SystemDebug.export_import, :export_service,service_hash,result)
            return result[:stdout] if result[:result] == 0
            return log_error("failed to export ",service_hash,result)
          end
        rescue Timeout::Error
          log_error_mesg('Export Timeout on Running Action ',cmd)
          return {}
        end
end

  def  import_service(params)
    
  end
end