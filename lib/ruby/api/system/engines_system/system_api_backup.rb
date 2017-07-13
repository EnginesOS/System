module SystemApiBackup
  def backup_system_files(out)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_files.sh', true, false, out)
  end

  def backup_system_db(out)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_db.sh', true, false, out)
  end

  def backup_system_registry(out)
    tree = @engines_api.registry_root
    out << YAML::dump(tree)
  end
  
  def restore_registry(out)
    reg = loadSystemService('registry')
    params = {
          container: reg,
          data_stream: out,
          command_line: ['/home/services/restore.sh'],
          log_error: true }
    result = @engines_api.exec_in_container(params)
    if result[:result] != 0
          result
        else
          true
        end
  end

  def backup_service_data(service_name, out)
    service = loadManagedService(service_name)
    params = {
      container: service,
      stream: out,
      command_line: ['/home/services/backup.sh'],
      log_error: true }
    result = @engines_api.exec_in_container(params)
    STDERR.puts(' BACKUP SERVICE ' + result.to_s)
    if result[:result] != 0
      result
    else
      true
    end
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

  def backup_engine_service(service_hash, out)
    @engines_api.backup_engine_service(service_hash, out)
  end
end