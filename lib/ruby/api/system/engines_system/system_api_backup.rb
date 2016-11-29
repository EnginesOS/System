module SystemApiBackup
  def backup_system_files(out)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_files.sh', true, false, out)
    
   end
 
   def backup_system_db(out)
     SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_db.sh', true, false, out)
   end
   
   def backup_system_registry(out)
     SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_registry.sh', true, false, out)
   end
   
   def backup_service_data(service_name,out)
    
   end
   
   def backup_engine_config(engine_name, out)
     
     SystemUtils.execute_command('/opt/engines/system/scripts/backup/engine_config.sh ' + engine_name , true, false, out)
   end
   
   def backup_engine_service(service_hash,out)
    
   end 
end