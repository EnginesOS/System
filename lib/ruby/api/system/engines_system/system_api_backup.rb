module SystemApiBackup
  def backup_system_files(out)
    STDERR.puts('backup system files to class ', + out.class.name)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_files.sh', true, false, out)
  end

  def engine_bundle(engine_name, out)
    export_engine_registry(engine_name)
    mk_engine_bundle_dir(engine_name)
    services = get_engines_persistent_services(engine_name)
    services.each do |service|
      begin
        service_out = engines_bundle_service_file(service)
        backup_engine_service(service_hash, service_out)
      ensure
        service_out.close unless service_out.nil?
      end
    end
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/engine_bundle.sh ' + engine_name, true, false, out)
  end

  def backup_system_db(out)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_db.sh', true, false, out)
  end

  def backup_system_registry(out)
    reg = loadSystemService('registry')
    params = {
      container: reg,
      stdout_stream: out,
      command_line: ['/home/engines/scripts/backup/backup.sh'],
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
      stdin_stream: out,
      command_line: ['/home/engines/scripts/backup/restore.sh'],
      log_error: true}
    result = @engines_api.exec_in_container(params)
    if result[:result] != 0
      result
    else
      true
    end
  end

  def restore_system_files(out, p)
    # STDERR.puts('RESTORE SYSTEM_' + out.class.name)
    #FixMe need to support path and $replace
    SystemUtils.execute_command('/opt/engines/system/scripts/restore/system_files.sh', true, out, nil)

  end

  def restore_engines
    # STDERR.puts('RESTORE engines' )
    getManagedEngines.each do |engine |
      #  STDERR.puts('engine' + engine.container_name.to_s)
      if engine.read_state == 'nocontainer'
        #  STDERR.puts('RESTORE engine' + engine.container_name.to_s)
        build_thr = @engines_api.restore_engine(engine)
        build_thr.join
      end
    end
  end

  def backup_service_data(service_name, out)
    service = loadManagedService(service_name)
    if service.is_running?
      params = {
        container: service,
        stdout_stream: out,
        command_line: ['/home/engines/scripts/backup/backup.sh'],
        log_error: true}
      result = @engines_api.exec_in_container(params)
      if result[:result] != 0
        result
        #    STDERR.puts(' BACKUP SERVICE ' + result.to_s)
      else
        true
      end
    end
  end

  def backup_engine_config(engine_name, out)
    export_engine_registry(engine_name)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/engine_config.sh ' + engine_name , true, false, out)
  end

  def engines_services_to_backup(engine)
    paths = {}
    n=0
    services = @engines_api.engines_services_to_backup(engine)
    services.each do |service|
      n+=1
      paths['service'+n.to_s] = engine + '/service/' + service[:publisher_namespace] + '/' + service[:type_path] + '/' + + service[:service_handle]
    end
    paths
  end

  def backup_engine_service(sh, out)
    # move following to @engines_api.
    #engine = loadManagedEngine(service_hash[:parent_engine])
    #engine.export_service_data(service_hash, out)
    @engines_api.backup_engine_service(sh, out)
  end

  private
  
  def mk_engine_bundle_dir(en)
    Dir.mkdir(SystemConfig.BackupTmpDir + '/'+ en)
  end
  
  def engines_bundle_service_file(sh)
    type_path = sh[:type_path].gsub(/\//,'.')
    fp = SystemConfig.BackupTmpDir + '/' \
    + sh[:parent_engine] \
    + '/' + type_path  \
    + '/' + sh[:service_handle]
    File.open(fp,'w')
  end

  def export_engine_registry(engine_name, f=nil)
    engine = loadManagedEngine(engine_name)
    if f.nil?
      engine = loadManagedEngine(engine_name)
      f = File.open(container_state_dir(engine) + '/registry.dump', 'w+')
      serialized_object = YAML::dump(@engines_api.engine_attached_services(engine_name))
    end
    STDERR.puts("\n\n v " + serialized_object.to_s)
    f.puts(serialized_object)
  ensure
    f.close unless f.nil?
  end
end