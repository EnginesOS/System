module EngineApiExportImport
  @@export_timeout=120
  def export_service(service_hash)
    SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash)
    cmd_dir = SystemConfig.BackupScriptsRoot + '/' + service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + '/' + service_hash[:service_handle] + '/'

    cmd = 'docker exec  ' + service_hash[:parent_engine] + ' ' + cmd_dir + '/backup.sh ' 
    SystemDebug.debug(SystemDebug.export_import, :export_service, cmd)
        begin
          result = {}
          Timeout.timeout(@@export_timeout) do
            thr = Thread.new { result = SystemUtils.execute_command(cmd, true) }
            thr.join
            SystemDebug.debug(SystemDebug.export_import, :export_service,service_hash,result)
            return result[:stdout] if result[:result] == 0
            return log_error_mesg("failed to export ",service_hash,result)
          end
        rescue Timeout::Error
          return log_error_mesg('Export Timeout on Running Action ',cmd)
        end
  rescue StandardError => e
    log_exception(e,'export service',service_hash)
end

  def import_service(params)  
    rescue StandardError => e
      log_exception(e,'import service',params)
  end
end