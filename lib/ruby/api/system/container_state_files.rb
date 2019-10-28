class ContainerStateFiles
  def self.build_running_service(service_name, service_type_dir)
    config_template_file_name = "#{service_type_dir}#{service_name}/config.yaml"
    if File.exist?(config_template_file_name)
      config_template = File.read(config_template_file_name)
      templator = Templater.new(nil)
      running_config = templator.process_templated_string(config_template)
      yam1_file_name = "#{service_type_dir}#{service_name}/running.yaml"
      yaml_file = File.new(yam1_file_name, 'w+')
      begin
        yaml_file.write(running_config)
      ensure
        yaml_file.close
      end
      true
    else
      SystemUtils.log_error_mesg('Running exist', service_name)
    end
  end
  
  def self.secretsdir(ca)
    "/var/lib/engines/secrets/#{ca[:c_type]}s/#{ca[:c_name]}"
  end

  def self.schedules_dir(ca)
    "#{self.container_state_dir(ca)}/schedules/"   
  end

  def self.schedules_file(ca)
    "#{self.schedules_dir(ca)}/schedules.yaml"
  end

  def self.actionator_dir(ca)
    "#{self.container_state_dir(ca)}/actionators/"
  end

  def self.container_flag_dir(ca)
    "#{self.container_state_dir(ca)}/run/flags/"
  end

  def self.kerberos_dir(ca)
    "/var/lib/engines/services/auth/etc/krb5kdc/#{ca[:c_type]}s/#{ca[:c_name]}"
  end

  def self.restart_flag_file(ca)
    "#{self.container_flag_dir(ca)}/restart_required"
  end

  def self.rebuild_flag_file(ca)
    "#{self.container_flag_dir(ca)}/rebuild_required"
  end

  def self.read_container_id(ca)
    cidfile = ContainerStateFiles.container_cid_file(ca)
    unless File.exist?(cidfile)
      -1
    else
      r = File.read(cidfile)
      r.gsub(/\s+/, '').strip
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
    '-1'
  end

  def self.create_container_dirs(ca)
    state_dir = ContainerStateFiles.container_state_dir(ca)
    unless File.directory?(state_dir)
      Dir.mkdir(state_dir)
      Dir.mkdir("#{state_dir}/run") unless Dir.exist?("#{state_dir}/run")
      Dir.mkdir("#{state_dir}/run/flags") unless Dir.exist?("#{state_dir}/run/flags")
      FileUtils.chown_R(nil, 'containers', "#{state_dir}/run")
      FileUtils.chmod_R('u+r', "#{state_dir}run")
      FileUtils.chmod_R('g+w', "#{state_dir}/run")
    end
    log_dir = ContainerStateFiles.container_log_dir(ca)
    Dir.mkdir(log_dir) unless File.directory?(log_dir)
    unless ca[:c_type] == 'engine'
      Dir.mkdir("#{state_dir}/configurations/") unless File.directory?("#{state_dir}/configurations")
      Dir.mkdir("#{state_dir}/configurations/default") unless File.directory?("#{state_dir}/configurations/default")
    end
    key_dir =  ContainerStateFiles.key_dir(ca)
    unless Dir.exist?(key_dir)
      Dir.mkdir(key_dir)  unless File.directory?(key_dir)
      FileUtils.chown(nil, 'containers',key_dir)
      FileUtils.chmod('g+w', key_dir)
    end
    true
  end

  def self.key_dir(ca)
    "#{SystemConfig.SSHStore}/#{ca[:c_type]}s/#{ca[:c_name]}"
  end

  def self.clear_container_var_run(ca)
    File.unlink("#{ContainerStateFiles.container_state_dir(ca)}/startup_complete") if File.exist?(ContainerStateFiles.container_state_dir(ca) + '/startup_complete')
    true
  end

  def self.container_cid_file(ca)
    "#{SystemConfig.CidDir}/#{ca[:c_name]}.cid"
  end

  def self.destroy_container(ca)
    File.delete(ContainerStateFiles.container_cid_file(ca)) if File.exist?(ContainerStateFiles.container_cid_file(ca))
  end

  def self.container_log_dir(ca)
    "#{SystemConfig.SystemLogRoot}/#{ca[:c_type]}s/#{ca[:c_name]}"
  end

  def self.container_ssh_keydir(ca)
    "#{SystemConfig.SSHStore}/#{ca[:c_type]}s/#{ca[:c_name]}"
  end

  def self.clear_cid_file(ca)
    cidfile = container_cid_file(ca)
    File.delete(cidfile) if File.exist?(cidfile)
  end

  def self.container_service_dir(sn)
    "#{SystemConfig.RunDir}/services/#{sn}"
  end

  def self.container_disabled_service_dir(sn)
    "#{SystemConfig.RunDir}/services-disabled/#{sn}"
  end

  def self.container_state_dir(ca)
    "#{SystemConfig.RunDir}/#{ca[:c_type]}s/#{ca[:c_name]}"
  end

end
