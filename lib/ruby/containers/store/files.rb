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

    def secrets_dir(cn)
      "/var/lib/engines/secrets/#{container_ns(cn)}"
    end

    def kerberos_dir(cn)
      "/var/lib/engines/services/auth/etc/krb5kdc/#{container_ns(cn)}"
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

    def key_dir(cn)
      "#{SystemConfig.SSHStore}/#{container_ns(cn)}"
    end

    def container_cid_file(cn)
      "#{SystemConfig.CidDir}/#{cn}.cid"
    end

    def container_log_dir(cn)
      "#{SystemConfig.SystemLogRoot}/#{container_ns(cn)}"
    end

    def container_ssh_keydir(cn)
      "#{SystemConfig.SSHStore}/#{container_ns(cn)}"
    end

    def container_state_dir(cn)
      "#{store_directory}/#{cn}"
    end

    def container_rflag_dir(cn)
      "#{container_state_dir(cn)}/run/flags"
    end

    def container_ns(cn)
      "#{container_type}s/#{cn}"
    end
  end
end
