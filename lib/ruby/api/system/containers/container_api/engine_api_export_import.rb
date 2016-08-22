module EngineApiExportImport
  @@export_timeout=120
  def export_service_data(container, service_hash, stream=nil)
    SystemDebug.debug(SystemDebug.export_import, :export_service, service_hash)
    cmd_dir = SystemConfig.BackupScriptsRoot + '/' + service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + '/' + service_hash[:service_handle] + '/'
   
    cmd = cmd_dir + '/backup.sh' 
    SystemDebug.debug(SystemDebug.export_import, :export_service, cmd)
        begin
          result = {}
          params = {:container => container, :command_line => [cmd], :log_error => true }
            params[:stream] =  stream unless stream.nil?
          Timeout.timeout(@@export_timeout) do
          thr = Thread.new { result = @engines_core.exec_in_container(params) }
            #SystemUtils.execute_command(cmd, true) }
            thr.join
            SystemDebug.debug(SystemDebug.export_import, :export_service,service_hash,'result code =' ,result[:result],params)
            return result[:stdout] if result[:result] == 0
            return log_error_mesg("failed to export ",service_hash,result)
          end
        rescue Timeout::Error
          return log_error_mesg('Export Timeout on Running Action ' +  params.to_s,cmd)
        end
  rescue StandardError => e
    log_exception(e,'export service',service_hash)
end

   
  def import_service_data(container, service_params, stream=nil)  
   
    service_hash = service_params[:service_connection]
    SystemDebug.debug(SystemDebug.export_import, :import_service, service_params,service_params[:import_method])
       cmd_dir = SystemConfig.BackupScriptsRoot + '/' + service_hash[:publisher_namespace] + '/' + service_hash[:type_path] + '/' + service_hash[:service_handle] + '/'
   if service_params[:import_method] == :replace  
     cmd = cmd_dir + '/replace.sh ' 
   else
     cmd = cmd_dir + '/restore.sh ' 
   end
    params = {:container => container, :command_line => [cmd], :log_error => true }
              params[:stream] =  stream unless stream.nil?
              params[:data] = service_params[:data]
       SystemDebug.debug(SystemDebug.export_import, :import_service, params,service_params)
           begin
             result = {}
             Timeout.timeout(@@export_timeout) do
               thr = Thread.new { result = @engines_core.exec_in_container(params) }
               thr.join
               SystemDebug.debug(SystemDebug.export_import, :import_service,'result ' ,result.to_s)
               return true if result[:result] == 0
               return log_error_mesg("failed to export ",service_params,params,result)
             end
           rescue Timeout::Error
             return log_error_mesg('Import Timeout on Running Action ',cmd)
           end
    rescue StandardError => e
      log_exception(e,'import service',service_params,params)
  end
end