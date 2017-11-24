module SystemApiBackup
  def backup_system_files(out)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_files.sh', true, false, out)
  end

  def backup_system_db(out)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_db.sh', true, false, out)
  end

  def backup_system_registry(out)
    reg = loadSystemService('registry')
    params = {
      container: reg,
      stream: out,
      command_line: ['/home/services/backup.sh'],
      log_error: true }
    result = @engines_api.exec_in_container(params)
    if result[:result] != 0
      result
    else
      true
    end
  end

  def restore_registry(out, p)
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

  def restore_system_files(out, p)
    STDERR.puts('RESTORE SYSTEM_' + out.class.name)
    #FixMe need to support path and $replace
    SystemUtils.execute_command('/opt/engines/system/scripts/restore/system_files.sh', true, out, nil)

  end

  def restore_engines
    STDERR.puts('RESTORE engines' )
    getManagedEngines.each do |engine |
      STDERR.puts('engine' + engine.container_name.to_s)
      if engine.read_state == 'nocontainer'
        STDERR.puts('RESTORE engine' + engine.container_name.to_s)
       build_thr = @engines_api.restore_engine(engine)
       build_thr.join
      end
    end
    #    reg = loadSystemService('system')
    #    params = {
    #          container: reg,
    #          data_stream: out,
    #          command_line: ['/home/services/restore.sh'],
    #          log_error: true }
    #    result = @engines_api.exec_in_container(params)
    #    if result[:result] != 0
    #          result
    #        else
    #          true
    #        end
  end

  def backup_service_data(service_name, out)
    service = loadManagedService(service_name)
    if service.is_running?
      params = {
        container: service,
        stream: out,
        command_line: ['/home/engines/scripts/backup/backup.sh'],
        log_error: true }
      result = @engines_api.exec_in_container(params)
      if result[:result] != 0
        result
        STDERR.puts(' BACKUP SERVICE ' + result.to_s)
      else
        true
      end
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