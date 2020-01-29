module Container
  require '/opt/engines/lib/ruby/exceptions/engines_exception.rb'
  class Store
    #self
    def file(n)
      File.new(n, 'r')
    end

    #self
    def file_exists?(name)
      n = file_name(name)
      if n.nil?
        false
      else
        File.exist?(n)
      end
    end

    #self
    def file_name(name)
      STDERR.puts("File NMA " * 10)
      STDERR.puts "#{container_type}"
      STDERR.puts "#{store_directory}/#{name}/running.yaml"
      "#{store_directory}/#{name}/running.yaml"
    end

    #self
    def store_directory
      "#{SystemConfig.RunDir}/#{container_type}s"
    end

    #self
    def container_ns(cn)
      "#{container_type}s/#{cn}"
    end

    #container managed container
    def read_container_id(cn)
      cidfile = container_cid_file(cn)
      unless File.exist?(cidfile)
        nil
      else
        r = File.read(cidfile)
        r.gsub(/\s+/, '').strip
      end
    rescue StandardError => e
      SystemUtils.log_exception(e)
      nil
    end

    # self
    def container_cid_file(cn)
      "#{SystemConfig.CidDir}/#{cn}.cid"
    end

    #DockFaceCreateOptions:
    def secrets_dir(cn)
      "/var/lib/engines/secrets/#{container_ns(cn)}"
    end

    #DockFaceCreateOptions:
    def kerberos_dir(cn)
      "/var/lib/engines/services/auth/etc/krb5kdc/#{container_ns(cn)}"
    end

    #DockFaceCreateOptions:
    def key_dir(cn)
      "#{SystemConfig.SSHStore}/#{container_ns(cn)}"
    end

    #  DockFace:DockFaceCreateOptions:ssh_keydir_mount
    def container_ssh_keydir(cn)
      "#{SystemConfig.SSHStore}/#{container_ns(cn)}"
    end

    #used by SystemAPI:ContainerSystemStateFiles:save_container_log
    #DockFaceCreateOptions:
    def container_log_dir(cn)
      "#{SystemConfig.SystemLogRoot}/#{container_ns(cn)}"
    end

    #service_doock system_api_backup blueprint_api containers engine_builder store
    def container_state_dir(cn)
      "#{store_directory}/#{cn}"
    end

    #ContainerApi:EngineApiStatusFlags:wait_for_startup
    def container_flag_dir(cn)
      "#{container_state_dir(cn)}/run/flags"
    end

    #ContainerApi:EngineApiStatusFlags:wait_for_startup
    def is_startup_complete?(cn)
      File.exist?("#{container_flag_dir(cn)}/startup_complete")
    end

    ####
    #ManagedContainerStatus
    def clear_debug(cn)
      df = "#{container_state_dir(cn)}/wait_before_shutdown"
      FileUtils.rm(fd) if File.exist?(fd)
    end

    def set_debug(cn)
      FileUtils.touch("#{container_state_dir(cn)}/wait_before_shutdown")
    end

    def restart_flag_file(cn)
      "#{container_flag_dir(cn)}/restart_required"
    end

    def restart_required?(cn)
      File.exist?(restart_flag_file(cn))
    end

    def restart_reason(cn)
      if File.exist?(restart_flag_file(cn))
        File.read(restart_flag_file(cn))
      else
        nil
      end
    rescue StandardError
      nil
    end

    def rebuild_flag_file(cn)
      "#{container_flag_dir(cn)}/rebuild_required"
    end

    def rebuild_required(cn)
      File.exist?(rebuild_flag_file(cn))
    end

    def rebuild_reason(cn)
      if File.exist?(rebuild_flag_file(cn))
        File.read(restart_flag_file(cn))
      else
        nil
      end
    rescue StandardError
      nil
    end
    #########

    ####builder

    def mark_restart_required(cn, reason)
      flag_file = restart_flag_file(cn)
      # Should not need once upon a time restart flag file might have been early  FileUtils.mkdir_p(container_flag_dir(cn)) unless Dir.exist?(container_flag_dir(cn))
      f = File.new(flag_file, 'w+')
      begin
        f.puts(reason)
      ensure
        f.close
      end
      File.chmod(0660, restart_flag_file)
      FileUtils.chown(nil, 'containers', restart_flag_file)
    end

    def schedules_dir(cn)
      "#{container_state_dir(cn)}/schedules/"
    end

    def schedules_file(cn)
      "#{schedules_dir(cn)}/schedules.yaml"
    end

    def actionator_dir(cn)
      "#{container_state_dir(cn)}/actionators/"
    end

    def init_engine_dirs(en)
      FileUtils.mkdir_p("#{container_state_dir(en)}/run") unless Dir.exist?("#{container_state_dir(en)}/run")
      FileUtils.mkdir_p(container_log_dir(en)) unless Dir.exist?(container_log_dir(en))
      FileUtils.mkdir_p(container_ssh_keydir(en)) unless Dir.exist?(container_ssh_keydir(en))
    end

    def save_build_report(cn, build_report)
      f = File.new("#{container_state_dir(cn)}/buildreport.txt", File::CREAT | File::TRUNC | File::RDWR, 0644)
      begin
        f.puts(build_report)
      ensure
        f.close
      end
    end

    #also used bu publicapi gui prefs
    def set_container_icon_url(cn, url)
      url_f = File.new("#{container_state_dir(cn)}/icon.url", 'w+')
      begin
        url_f.puts(url)
      ensure
        url_f.close
      end
    rescue StandardError => e
      url_f.close unless url_f.nil?
      raise e
    end
    ###

    #from docker_info_collector
    # from container_dock:engines_api_system
    #EnginesSystem:ContainerSystemStateFiles:delete_container_configs
    def clear_cid_file(cn)
      cidfile = container_cid_file(cn)
      File.delete(cidfile) if File.exist?(cidfile)
    end

    #Container_Dock:EnginesApiSystem:create_container
    def clear_container_var_run(ca)
      File.unlink("#{container_state_dir(ca)}/startup_complete") if File.exist?(container_state_dir(ca) + '/startup_complete')
      true
    end

    def create_container_dirs(cn)
      state_dir = container_state_dir(cn)
      unless File.directory?(state_dir)
        Dir.mkdir(state_dir)
        Dir.mkdir("#{state_dir}/run") unless Dir.exist?("#{state_dir}/run")
        Dir.mkdir("#{state_dir}/run/flags") unless Dir.exist?("#{state_dir}/run/flags")
        FileUtils.chown_R(nil, 'containers', "#{state_dir}/run")
        FileUtils.chmod_R('u+r', "#{state_dir}run")
        FileUtils.chmod_R('g+w', "#{state_dir}/run")
      end
      log_dir = container_log_dir(cn)
      Dir.mkdir(log_dir) unless File.directory?(log_dir)
      Dir.mkdir("#{state_dir}/configurations/") unless File.directory?("#{state_dir}/configurations")
      Dir.mkdir("#{state_dir}/configurations/default") unless File.directory?("#{state_dir}/configurations/default")
      key_dir = key_dir(cn)
      unless Dir.exist?(key_dir)
        Dir.mkdir(key_dir)  unless File.directory?(key_dir)
        FileUtils.chown(nil, 'containers',key_dir)
        FileUtils.chmod('g+w', key_dir)
      end
      true
    end

    #EventHandler:is_engines_container_event
    def has_config?(cn)
      unless container_type == 'app'
        File.exist?("#{container_state_dir(cn)}/config.yaml") | File.exist?("#{container_state_dir(cn)}/running.yaml")
      else
        File.exist?("#{container_state_dir(cn)}/running.yaml")
      end
    end

  end
end
