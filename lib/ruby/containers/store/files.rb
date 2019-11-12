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
    def container_rflag_dir(cn)
      "#{container_state_dir(cn)}/run/flags"
    end

    #ContainerApi:EngineApiStatusFlags:wait_for_startup
    def is_startup_complete?(ca)
      File.exist?("#{container_rflag_dir(ca)}/startup_complete")
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

    #from docker_info_collector
    # from container_dock:engines_api_system
    #EnginesSystem:ContainerSystemStateFiles:delete_container_configs
    def clear_cid_file(cn)
      cidfile = container_cid_file(cn)
      File.delete(cidfile) if File.exist?(cidfile)
    end

  end
end
