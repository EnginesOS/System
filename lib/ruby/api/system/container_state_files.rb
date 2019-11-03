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

  def self.secrets_dir(ca)
    "/var/lib/engines/secrets/#{container_ns(ca)}"
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
    "/var/lib/engines/services/auth/etc/krb5kdc/#{container_ns(ca)}"
  end

  def self.restart_flag_file(ca)
    "#{self.container_flag_dir(ca)}/restart_required"
  end

  def self.rebuild_flag_file(ca)
    "#{self.container_flag_dir(ca)}/rebuild_required"
  end

  def self.read_container_id(ca)
    cidfile = self.container_cid_file(ca)
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
    state_dir = self.container_state_dir(ca)
    unless File.directory?(state_dir)
      Dir.mkdir(state_dir)
      Dir.mkdir("#{state_dir}/run") unless Dir.exist?("#{state_dir}/run")
      Dir.mkdir("#{state_dir}/run/flags") unless Dir.exist?("#{state_dir}/run/flags")
      FileUtils.chown_R(nil, 'containers', "#{state_dir}/run")
      FileUtils.chmod_R('u+r', "#{state_dir}run")
      FileUtils.chmod_R('g+w', "#{state_dir}/run")
    end
    log_dir = self.container_log_dir(ca)
    Dir.mkdir(log_dir) unless File.directory?(log_dir)
    unless ca[:c_type] == 'engine'
      Dir.mkdir("#{state_dir}/configurations/") unless File.directory?("#{state_dir}/configurations")
      Dir.mkdir("#{state_dir}/configurations/default") unless File.directory?("#{state_dir}/configurations/default")
    end
    key_dir =  self.key_dir(ca)
    unless Dir.exist?(key_dir)
      Dir.mkdir(key_dir)  unless File.directory?(key_dir)
      FileUtils.chown(nil, 'containers',key_dir)
      FileUtils.chmod('g+w', key_dir)
    end
    true
  end

  def self.key_dir(ca)
    "#{SystemConfig.SSHStore}/#{container_ns(ca)}"
  end

  def self.clear_container_var_run(ca)
    File.unlink("#{self.container_state_dir(ca)}/startup_complete") if File.exist?(self.container_state_dir(ca) + '/startup_complete')
    true
  end

  def self.container_cid_file(ca)
    "#{SystemConfig.CidDir}/#{ca[:c_name]}.cid"
  end

  def self.set_debug(ca)
    FileUtils.touch("#{container_state_dir(ca)}/wait_before_shutdown")
  end

  def self.clear_debug(ca)
    df = "#{container_state_dir(ca)}/wait_before_shutdown"
    FileUtils.rm(fd) if File.exist?(fd)
  end

  def self.destroy_container(ca)
    File.delete(self.container_cid_file(ca)) if File.exist?(self.container_cid_file(ca))
  end

  def self.container_log_dir(ca)
    "#{SystemConfig.SystemLogRoot}/#{container_ns(ca)}"
  end

  def self.container_ssh_keydir(ca)
    "#{SystemConfig.SSHStore}/#{container_ns(ca)}"
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
    "#{SystemConfig.RunDir}/#{container_ns(ca)}"
  end

  def self.container_info_tree_dir(ca)
    "#{SystemConfig.InfoTreeDir}/#{container_ns(ca)}"
  end

  def self.is_startup_complete?(ca)
    File.exist?("#{container_rflag_dir(ca)}/startup_complete")
  end

  def self.container_ns(ca)
    "#{ca[:c_type]}s/#{ca[:c_name]}"
  end

  def self.init_container_info_dir(p)
    if p.is_a?(Hash)
      keys = p[:keys]
      ca = p
    else
      ca = {c_type: p.ctype, c_name: p.container_name}
      keys = {uid: p.cont_user_id}
    end
    write_info_tree(ca, keys)

  end

  def self.write_info_tree(ca, keys)
    FileUtils.mkdir_p(self.container_info_tree_dir(ca)) unless File.exists?(self.container_info_tree_dir(ca))
    unless keys.nil?
      keys.each do |k, v|
        next if v.nil?
        kf = File.new("#{self.container_info_tree_dir(ca)}/#{k}",'w')
        begin
          kf.write(v.to_s)
        ensure
          kf.close
        end
      end
    end
  end

  def self.rebuild_required?(ca)
    File.exist?(self.rebuild_flag_file(ca))
  end

  def self.restart_reason(ca)
    if File.exist?(self.restart_flag_file(ca))
      File.read(self.restart_flag_file(ca))
    else
      false
    end
  end

  def self.has_config?(ca)
    unless ca[:c_type] == 'app'
      File.exist?("#{self.container_state_dir(ca)}/config.yaml")
    else
      File.exist?("#{self.container_state_dir(ca)}/running.yaml")
    end
  end

  def self.rebuild_reason(ca)
    if File.exist?(self.rebuild_flag_file(ca))
      File.read(self.restart_flag_file(ca))
    else
      false
    end
  end

  def self.restart_required?(ca)
    File.exist?(self.restart_flag_file(ca))
  end

  def self.load_engine_actionators(ca)
    #   SystemDebug.debug(SystemDebug.actions, container, actionator_dir(container) + '/actionators.yaml')
    if File.exist?("#{self.actionator_dir(ca)}/actionators.yaml")
      yaml = File.read("#{self.actionator_dir(ca)}/actionators.yaml")
      actionators = YAML::load(yaml)
      #     SystemDebug.debug(SystemDebug.actions,container ,actionators)
      actionators if actionators.is_a?(Hash)
    else
      {}
    end
  end

  def self.get_build_report(en)
    c = self.container_state_dir({c_name: en, c_type: 'app'})
    if File.exist?("#{c}/buildreport.txt")
      File.read("#{c}/buildreport.txt")
    else
      raise EnginesException.new(error_hash("No Build Report:#{c}/buildreport.txt"))
    end
  end

  def self.save_build_report(ca, build_report)
    f = File.new("#{container_state_dir(ca)}/buildreport.txt", File::CREAT | File::TRUNC | File::RDWR, 0644)
    begin
      f.puts(build_report)
    ensure
      f.close
    end
  end

  def self.load_schedules(ca)
    YAML::load(File.read(self.schedules_file(ca)))
  rescue
    nil
  end

  def self.write_actionators(ca, actionators)
    Dir.mkdir_p(self.actionator_dir(ca)) unless Dir.exist?(self.actionator_dir(ca))
    serialized_object = YAML.dump(actionators)
    f = File.new("#{self.actionator_dir(ca)}/actionators.yaml", File::CREAT | File::TRUNC | File::RDWR, 0644)
    begin
      f.puts(serialized_object)
      f.flush()
    ensure
      f.close
    end
  end

  def self.follow_build(out)
    build_log_file = File.new(self.BuildOutputFile, 'r')
    begin
      while
        begin
          bytes = build_log_file.read_nonblock(1000)
        rescue IO::WaitReadable
          retry
        rescue EOFError
          out.write(bytes.force_encoding(Encoding::ASCII_8BIT)) # was UTF_8
        rescue => e
          out.write(bytes)
          'Maybe ' + e.to_s
        end
        out.write(bytes.force_encoding(Encoding::ASCII_8BIT)) # was UTF_8
      end
    ensure
      build_log_file.close
    end
  end

  def self.flag_restart_required(ca, restart_reason)
    # FixME this should be elsewhere
    restart_flag_file = self.restart_flag_file(ca)
    FileUtils.mkdir_p(self.container_flag_dir(ca)) unless Dir.exist?(self.container_flag_dir(ca))
    f = File.new(restart_flag_file, 'w+')
    begin
      f.puts(restart_reason)
    ensure
      f.close
    end
    File.chmod(0660, restart_flag_file)
    FileUtils.chown(nil, 'containers', restart_flag_file)
  end

  def self.remove_info_tree(ca)
    if File.exists?(self.container_info_tree_dir(ca))
      FileUtils.rm_f(self.container_info_tree_dir(ca))
    end
  end

  def self.load_pubkey(ca, cmd)
    kfn = "#{self.container_ssh_keydir(ca)}/#{cmd}_rsa.pub"
    if File.exists?(kfn)
      k = File.read(kfn)
      k.split(' ')[1]
    else
      ''
    end
  end

  def self.set_container_icon_url(ca, url)
    url_f = File.new("#{self.container_state_dir(ca)}/icon.url", 'w+')
    begin
      url_f.puts(url)
    ensure
      url_f.close
    end
  rescue StandardError => e
    url_f.close unless url_f.nil?
    raise e
  end

  def self.container_icon_url(ca)
    if File.exists?("#{self.container_state_dir(ca)}/icon.url")
      url_f = File.new("#{self.container_state_dir(ca)}/icon.url", 'r')
      begin
        url = url_f.gets(url)
      ensure
        url_f.close
      end
      url.strip
    else
      nil
    end
  rescue StandardError => e
    url_f.close unless url_f.nil?
    raise e
  end

  def self.container_rflag_dir(ca)
    "#{self.container_state_dir(ca)}/run/flags"
  end

  def self.init_engine_dirs(en)
    ca = {c_type: 'app', c_name: en}
    FileUtils.mkdir_p("#{self.container_state_dir(ca)}/run") unless Dir.exist?("#{self.container_state_dir(ca)}/run")
    FileUtils.mkdir_p("#{self.container_state_dir(ca)}/run") unless Dir.exist?("#{self.container_state_dir(ca)}/run")
    FileUtils.mkdir_p(self.container_log_dir(ca)) unless Dir.exist?(self.container_log_dir(ca))
    FileUtils.mkdir_p(self.container_ssh_keydir(ca)) unless Dir.exist?(self.container_ssh_keydir(ca))
  end
end
