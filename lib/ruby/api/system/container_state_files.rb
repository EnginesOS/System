class ContainerStateFiles

  class << self
    def build_running_service(service_name, service_type_dir)
      config_template_file_name = "#{service_type_dir}/#{service_name}/config.yaml"
      STDERR.puts("Buildig runnings from #{config_template_file_name}")
      if File.exist?(config_template_file_name)
        config_template = File.read(config_template_file_name)
        templator = Templater.new(nil)
        running_config = templator.process_templated_string(config_template)
        yam1_file_name = "#{service_type_dir}/#{service_name}/running.yaml"
        yaml_file = File.new(yam1_file_name, 'w+')
        begin
          yaml_file.write(running_config)
          STDERR.puts("Built runnings from #{running_config}")
        ensure
          yaml_file.close
        end
        true
      else
        SystemUtils.log_error_mesg('Running exist', service_name)
      end
    rescue StandardError => e
      STDERR.puts("#{e}")
      raise e
    end
  end

  class << self # container store directories & files
    def secrets_dir(ca)
      "/var/lib/engines/secrets/#{container_ns(ca)}"
    end

    def kerberos_dir(ca)
      "/var/lib/engines/services/auth/etc/krb5kdc/#{container_ns(ca)}"
    end

    def schedules_dir(ca)
      "#{container_state_dir(ca)}/schedules/"
    end

    def schedules_file(ca)
      "#{schedules_dir(ca)}/schedules.yaml"
    end

    def actionator_dir(ca)
      "#{container_state_dir(ca)}/actionators/"
    end

    def key_dir(ca)
      "#{SystemConfig.SSHStore}/#{container_ns(ca)}"
    end

    def container_cid_file(ca)
      "#{SystemConfig.CidDir}/#{ca[:c_name]}.cid"
    end

    def container_log_dir(ca)
      "#{SystemConfig.SystemLogRoot}/#{container_ns(ca)}"
    end

    def container_ssh_keydir(ca)
      "#{SystemConfig.SSHStore}/#{container_ns(ca)}"
    end

    def container_service_dir(sn)
      "#{SystemConfig.RunDir}/services/#{sn}"
    end

    def container_disabled_service_dir(sn)
      "#{SystemConfig.RunDir}/services-disabled/#{sn}"
    end

    def container_state_dir(ca)
      "#{SystemConfig.RunDir}/#{container_ns(ca)}"
    end

    def container_rflag_dir(ca)
      "#{container_state_dir(ca)}/run/flags"
    end
  end

  class << self
    def container_flag_dir(ca)
      "#{container_state_dir(ca)}/run/flags/"
    end

    def restart_flag_file(ca)
      "#{container_flag_dir(ca)}/restart_required"
    end

    def rebuild_flag_file(ca)
      "#{container_flag_dir(ca)}/rebuild_required"
    end

    def read_container_id(ca)
      cidfile = container_cid_file(ca)
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

    def container_info_tree_dir(ca)
      "#{SystemConfig.InfoTreeDir}/#{container_ns(ca)}"
    end

    def is_startup_complete?(ca)
      File.exist?("#{container_rflag_dir(ca)}/startup_complete")
    end

    def container_ns(ca)
      "#{ca[:c_type]}s/#{ca[:c_name]}"
    end

    def rebuild_required?(ca)
      File.exist?(rebuild_flag_file(ca))
    end

    def restart_reason(ca)
      if File.exist?(restart_flag_file(ca))
        File.read(restart_flag_file(ca))
      else
        false
      end
    end

    def has_config?(ca)
      unless ca[:c_type] == 'app'
        File.exist?("#{container_state_dir(ca)}/config.yaml")
      else
        File.exist?("#{container_state_dir(ca)}/running.yaml")
      end
    end

    def rebuild_reason(ca)
      if File.exist?(rebuild_flag_file(ca))
        File.read(restart_flag_file(ca))
      else
        false
      end
    end

    def restart_required?(ca)
      File.exist?(restart_flag_file(ca))
    end

    def flag_restart_required(ca, restart_reason)
      # FixME this should be elsewhere
      restart_flag_file = restart_flag_file(ca)
      FileUtils.mkdir_p(container_flag_dir(ca)) unless Dir.exist?(container_flag_dir(ca))
      f = File.new(restart_flag_file, 'w+')
      begin
        f.puts(restart_reason)
      ensure
        f.close
      end
      File.chmod(0660, restart_flag_file)
      FileUtils.chown(nil, 'containers', restart_flag_file)
    end
  end

  class << self
    def set_debug(ca)
      FileUtils.touch("#{container_state_dir(ca)}/wait_before_shutdown")
    end

    def clear_debug(ca)
      df = "#{container_state_dir(ca)}/wait_before_shutdown"
      FileUtils.rm(fd) if File.exist?(fd)
    end
  end

  class << self
    def create_container_dirs(ca)
      state_dir = container_state_dir(ca)
      unless File.directory?(state_dir)
        Dir.mkdir(state_dir)
        Dir.mkdir("#{state_dir}/run") unless Dir.exist?("#{state_dir}/run")
        Dir.mkdir("#{state_dir}/run/flags") unless Dir.exist?("#{state_dir}/run/flags")
        FileUtils.chown_R(nil, 'containers', "#{state_dir}/run")
        FileUtils.chmod_R('u+r', "#{state_dir}run")
        FileUtils.chmod_R('g+w', "#{state_dir}/run")
      end
      log_dir = container_log_dir(ca)
      Dir.mkdir(log_dir) unless File.directory?(log_dir)
      unless ca[:c_type] == 'engine'
        Dir.mkdir("#{state_dir}/configurations/") unless File.directory?("#{state_dir}/configurations")
        Dir.mkdir("#{state_dir}/configurations/default") unless File.directory?("#{state_dir}/configurations/default")
      end
      key_dir =  key_dir(ca)
      unless Dir.exist?(key_dir)
        Dir.mkdir(key_dir)  unless File.directory?(key_dir)
        FileUtils.chown(nil, 'containers',key_dir)
        FileUtils.chmod('g+w', key_dir)
      end
      true
    end

    def destroy_container(ca)
      File.delete(container_cid_file(ca)) if File.exist?(container_cid_file(ca))
    end

    def clear_container_var_run(ca)
      File.unlink("#{container_state_dir(ca)}/startup_complete") if File.exist?(container_state_dir(ca) + '/startup_complete')
      true
    end

    def clear_cid_file(ca)
      cidfile = container_cid_file(ca)
      File.delete(cidfile) if File.exist?(cidfile)
    end

    def init_container_info_dir(p)
      if p.is_a?(Hash)
        keys = p[:keys]
        ca = p
      else
        ca = {c_type: p.ctype, c_name: p.container_name}
        keys = {uid: p.cont_user_id}
      end
      write_info_tree(ca, keys)
    end

    def init_engine_dirs(en)
      ca = {c_type: 'app', c_name: en}
      FileUtils.mkdir_p("#{container_state_dir(ca)}/run") unless Dir.exist?("#{container_state_dir(ca)}/run")
      FileUtils.mkdir_p("#{container_state_dir(ca)}/run") unless Dir.exist?("#{container_state_dir(ca)}/run")
      FileUtils.mkdir_p(container_log_dir(ca)) unless Dir.exist?(container_log_dir(ca))
      FileUtils.mkdir_p(container_ssh_keydir(ca)) unless Dir.exist?(container_ssh_keydir(ca))
    end

    def write_info_tree(ca, keys)
      FileUtils.mkdir_p(container_info_tree_dir(ca)) unless File.exists?(container_info_tree_dir(ca))
      unless keys.nil?
        keys.each do |k, v|
          next if v.nil?
          kf = File.new("#{container_info_tree_dir(ca)}/#{k}",'w')
          begin
            kf.write(v.to_s)
          ensure
            kf.close
          end
        end
      end
    end

    def remove_info_tree(ca)
      if File.exists?(container_info_tree_dir(ca))
        FileUtils.rm_f(container_info_tree_dir(ca))
      end
    end
  end

  class << self
    def load_engine_actionators(ca)
      #   SystemDebug.debug(SystemDebug.actions, container, actionator_dir(container) + '/actionators.yaml')
      if File.exist?("#{actionator_dir(ca)}/actionators.yaml")
        yaml = File.read("#{actionator_dir(ca)}/actionators.yaml")
        actionators = YAML::load(yaml)
        #     SystemDebug.debug(SystemDebug.actions,container ,actionators)
        actionators if actionators.is_a?(Hash)
      else
        {}
      end
    end

    def load_schedules(ca)
      YAML::load(File.read(schedules_file(ca)))
    rescue
      nil
    end

    def write_actionators(ca, actionators)
      Dir.mkdir_p(actionator_dir(ca)) unless Dir.exist?(actionator_dir(ca))
      serialized_object = YAML.dump(actionators)
      f = File.new("#{actionator_dir(ca)}/actionators.yaml", File::CREAT | File::TRUNC | File::RDWR, 0644)
      begin
        f.puts(serialized_object)
        f.flush()
      ensure
        f.close
      end
    end
  end

  class << self
    def get_build_report(en)
      c = container_state_dir({c_name: en, c_type: 'app'})
      if File.exist?("#{c}/buildreport.txt")
        File.read("#{c}/buildreport.txt")
      else
        raise EnginesException.new(error_hash("No Build Report:#{c}/buildreport.txt"))
      end
    end

    def save_build_report(ca, build_report)
      f = File.new("#{container_state_dir(ca)}/buildreport.txt", File::CREAT | File::TRUNC | File::RDWR, 0644)
      begin
        f.puts(build_report)
      ensure
        f.close
      end
    end

    def follow_build(out)
      build_log_file = File.new(BuildOutputFile, 'r')
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
  end

  class << self
    def load_pubkey(ca, cmd)
      kfn = "#{container_ssh_keydir(ca)}/#{cmd}_rsa.pub"
      if File.exists?(kfn)
        k = File.read(kfn)
        k.split(' ')[1]
      else
        ''
      end
    end
  end

  class << self
    def set_container_icon_url(ca, url)
      url_f = File.new("#{container_state_dir(ca)}/icon.url", 'w+')
      begin
        url_f.puts(url)
      ensure
        url_f.close
      end
    rescue StandardError => e
      url_f.close unless url_f.nil?
      raise e
    end

    def container_icon_url(ca)
      if File.exists?("#{container_state_dir(ca)}/icon.url")
        url_f = File.new("#{container_state_dir(ca)}/icon.url", 'r')
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
  end
end
