module SystemApiBackup
  
  def backup_system_files(out)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/system_files.sh', true, false, out)
  end

  def restore_engine_bundle(istream, params)
    SystemUtils.execute_command('/opt/engines/system/scripts/backup/import_engine_bundle.sh ' + params[:engine_name].to_s, false, istream , nil)
    begin
      reg_file = File.open(SystemConfig.BackupTmpDir + '/' + params[:engine_name] + '/opt/engines/run/apps/' + params[:engine_name] + '/registry.dump')
      registry = YAML::load(reg_file)
    ensure
      reg_file.close unless reg_file.nil?
    end
    services = @engines_api.import_engine_registry(registry)
    
    re_install_engine(params[:engine_name])
  end

  def stream_engine_bundle(engine_name, out)
    export_engine_registry(engine_name)
    mk_engine_bundle_dir(engine_name)
    services = @engines_api.get_engine_persistent_services({parent_engine: engine_name, container_type: 'app' })
    services.each do |sh|
      make_service_dir(sh)
      if is_es_filesystem?(sh).is_a?(TrueClass)
        link_in_fs(sh)
      else
        begin
          service_out = engines_bundle_service_file(sh)
          backup_engine_service(sh, service_out)
        ensure
          service_out.close unless service_out.nil?
        end
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
    loadManagedEngine(sh[:parent_engine]).export_service_data(sh, out)
  end

  private

  def is_es_filesystem?(sh)
    if sh[:publisher_namespace] == 'EnginesSystem' && sh[:type_path] == 'filesystem/local/filesystem'
      true
    else
      false
    end
  end

  def link_in_fs(sh)
    #SystemConfig.LocalFSVolHome + '/' + sh[:parent_engine] + '/' + sh[:service_handle],
    #FileUtils.touch(SystemConfig.BackupTmpDir + '/' + service_path(sh) + '/' + sh[:service_handle])
    lf = File.open(SystemConfig.BackupTmpDir + '/' + service_path(sh) + '/' + sh[:service_handle] + '.lnk', 'w')
    lf.puts(service_path(sh))
  ensure
    lf.close unless lf.nil?
  end

  def mk_engine_bundle_dir(en)
    dn = SystemConfig.BackupTmpDir + '/'+ en
    if Dir.exist?(dn)
      FileUtils.rm_r(dn, :force => true )
    end
    FileUtils.mkdir_p(SystemConfig.BackupTmpDir + '/'+ en)
  end

  def service_path(sh)
    sh[:parent_engine] + '/' + sh[:type_path]
  end

  def make_service_dir(sh)
    FileUtils.mkdir_p(SystemConfig.BackupTmpDir + '/' + service_path(sh))
  end

  def engines_bundle_service_file(sh)
    File.open(SystemConfig.BackupTmpDir + '/' + service_path(sh) + '/' + sh[:service_handle], 'w')
  end

  def export_engine_registry(engine_name, f=nil)
    serialized_object = YAML::dump(@engines_api.engine_attached_services(engine_name))
    if f.nil?
      engine = loadManagedEngine(engine_name)
      f = File.open(container_state_dir(engine) + '/registry.dump', 'w+')
    end
    f.puts(serialized_object)
  ensure
    f.close unless f.nil?
  end
end