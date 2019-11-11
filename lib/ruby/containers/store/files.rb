module Container
  class Store

    def file(name)
      File.new(file_name(name), 'r')
    end

    def file_exists?(name)
      File.exist?(file_name(name))
    end

    def file_name(name)
      "#{store_directory}/#{name}/running.yaml"
    end

    def store_directory
      "#{SystemConfig.RunDir}/#{container_type}s"
    end

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

    def container_state_dir(ca)
      "#{SystemConfig.RunDir}/#{container_ns(ca)}"
    end

    def container_rflag_dir(ca)
      "#{container_state_dir(ca)}/run/flags"
    end

    def container_ns(ca)
      "#{ca[:c_type]}s/#{ca[:c_name]}"
    end
  end
end
