module ConfigureServicesBackup
  def configure_services_backup(services)
    log_build_output('Creating Backup Scripts')
    services.each do |service|
      next unless service[:persistent] == true
      script_src_dir = SystemConfig.BackupScriptsSrcRoot + '/' + service[:publisher_namespace] + '/' + service[:type_path]
      install_backup_scripts(service, script_src_dir)
      end
  end

  def install_backup_scripts(service, script_src_dir)
    return unless Dir.exists?(script_src_dir)
    destdir = SystemConfig.BackupScriptsRoot + '/' + service[:publisher_namespace] + '/' + service[:type_path] + '/' + service[:service_handle] + '/'
    FileUtils.mkdir_p(basedir + destdir ) unless Dir.exist?(basedir + destdir )
    SystemDebug.debug(SystemDebug.builder,script_src_dir,destdir )
      Dir.entries(script_src_dir).each do |script_src_file |
        SystemDebug.debug(SystemDebug.builder,script_src_file,destdir )
        next unless File.file?(script_src_dir + '/' + script_src_file)        
        script_src = File.read(script_src_dir + '/' + script_src_file)         
        write_software_script_file(destdir + script_src_file, script_src)      
      end
  end
end