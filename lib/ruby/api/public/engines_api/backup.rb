module PublicApiBackup
  
  def backup_system_files(out)
    @system_api.backup_system_files(out)
  end

  def backup_system_db(out)
    @system_api.backup_system_db(out)
  end
  
  def backup_system_registry(out)
    @system_api.backup_system_registry(out)
  end
  
  def backup_service_data(service_name,out)
    @system_api.backup_service_data(service_name,out)
  end
  
  def backup_engine_config(engine_name, out)
    
    @system_api.backup_engine_config(engine_name, out)
  end
  
  def backup_engine_service(service_hash,out)
    @system_api.backup_engine_service(service_hash,out)
  end
  
  def engines_services_to_backup
    
    @system_api.engines_services_to_backup()
  end
end