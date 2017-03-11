module SystemApiBackup
  def backup_system_files(out)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_files.sh', true, false, out)
    
   end
 
   def backup_system_db(out)
     SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_db.sh', true, false, out)
   end
   
   def backup_system_registry(out)
   tree =  @engines_api.get_registry
 #  STDERR.puts(' TREE is ' + tree.to_yaml )
     out << tree.to_yaml
   end
   
   def backup_service_data(service_name,out)
     service = loadManagedService(service_name)
     return service if service.is_a?(EnginesError)
     result = {}
     params = {:container => service, :stream => out, :command_line => ['/home/services/backup.sh'], :log_error => true }
       
     result = @engines_api.exec_in_container(params)
  #   STDERR.puts(' service backup ' + params.to_s + ' returned ' + result.to_s ) 
     return result if result.is_a?(EnginesError)
     return result if result[:result] !=0
      true
   end
   
   def backup_engine_config(engine_name, out)
     
     SystemUtils.execute_command('/opt/engines/system/scripts/backup/engine_config.sh ' + engine_name , true, false, out)
   end
   
  def engines_services_to_backup(engine)
    paths = {}
      n=0
   services = @engines_api.engines_services_to_backup(engine)
   services.each do |service|
     n+=1
    paths['service'+n.to_s] =  engine + '/service/' + service[:publisher_namespace] + '/' + service[:type_path] + '/' + + service[:service_handle]       
   end
    paths
  end
  
   def backup_engine_service(service_hash,out)
   
     @engines_api.backup_engine_service(service_hash,out)
     
   end 
end