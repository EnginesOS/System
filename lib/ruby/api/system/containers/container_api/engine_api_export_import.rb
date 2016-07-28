module EngineApiExportImport
  @@export_timeout=120
  def export_service_data(container, service_hash)
    SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash)
    cmd_dir = SystemConfig.BackupScriptsRoot + '/' + service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + '/' + service_hash[:service_handle] + '/'
   
    cmd = cmd_dir + '/backup.sh' 
    SystemDebug.debug(SystemDebug.export_import, :export_service, cmd)
        begin
          result = {}
          Timeout.timeout(@@export_timeout) do
          thr = Thread.new { result = @engines_core.exec_in_container(container, [cmd]) }
            #SystemUtils.execute_command(cmd, true) }
            thr.join
            SystemDebug.debug(SystemDebug.export_import, :export_service,service_hash,'result code =' ,result[:result])
            return result[:stdout] if result[:result] == 0
            return log_error_mesg("failed to export ",service_hash,result)
          end
        rescue Timeout::Error
          return log_error_mesg('Export Timeout on Running Action ',cmd)
        end
  rescue StandardError => e
    log_exception(e,'export service',service_hash)
end

   
  def import_service_data(container, params)  
   
    service_hash = params[:service_connection]
    SystemDebug.debug(SystemDebug.export_import, :import_service, service_hash,params[:import_method])
       cmd_dir = SystemConfig.BackupScriptsRoot + '/' + service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + '/' + service_hash[:service_handle] + '/'
   if params[:import_method] == :replace  
     cmd = 'docker exec  -i ' + service_hash[:parent_engine] + ' ' + cmd_dir + '/replace.sh ' 
   else
     cmd = 'docker exec -i  ' + service_hash[:parent_engine] + ' ' + cmd_dir + '/restore.sh ' 
   end
       
       SystemDebug.debug(SystemDebug.export_import, :import_service, cmd)
           begin
             result = {}
             Timeout.timeout(@@export_timeout) do
               thr = Thread.new { result = SystemUtils.execute_command(cmd, true, params[:data]) }
               thr.join
               SystemDebug.debug(SystemDebug.export_import, :import_service,'result code =' ,result[:result])
               return true if result[:result] == 0
               return log_error_mesg("failed to export ",params,result)
             end
           rescue Timeout::Error
             return log_error_mesg('Import Timeout on Running Action ',cmd)
           end
    rescue StandardError => e
      log_exception(e,'import service',params)
  end
end