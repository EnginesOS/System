module Container
  class Store
    #self
    def file(name)
      File.new(file_name(name), 'r')
    end

    #self
    def file_exists?(name)
      File.exist?(file_name(name))
    end

    #self
    def file_name(name)
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

  end
end
