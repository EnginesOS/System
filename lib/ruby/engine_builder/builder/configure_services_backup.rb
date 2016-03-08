module ConfigureServicesBackup
  def configure_services_backup(services)
    services.each do |service|
      next unless service[:persistent] == true
      script__src_dir = SystemConfig.BackupScriptsSrcRoot + '/' + service[:publisher_namespace] + '/' + service[:type_path]
      install_backup_scripts(service, script_src_dir)
      end
  end

  def install_backup_scripts(service, script_src_dir)
    destdir = SystemConfig.BackupScriptsRoot + '/' + service[:publisher_namespace] + '/' + service[:type_path] + '/'
      
      Dir(destdir).glob('*.rb').each do |script_src_file |
        script_src = File.read(script_src_file)
        write_software_script_file(destdir + script_src_file, script_src)      
      end
  end
  
end