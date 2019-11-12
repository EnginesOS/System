require_relative 'store'

module Container
  class Memento

    class << self
      def from_yaml(yaml)
        YAML::load(yaml)
      rescue StandardError => e
        STDERR.puts('Problem ' + e.to_s)
        STDERR.puts('With: ' + yaml.to_s)
        raise e
      end
    end

    # for Container
    attr_reader :ctype,
      :memory,
      :container_name,
      :image,
      :web_port,
      :volumes,
      :mapped_ports,
      :environments,
      :setState

    attr_accessor :last_error,
      :last_result,
      :arguments

    # for ManagedContainer
    attr_reader :framework,
      :runtime,
      :repository,
      :data_uid,
      :data_gid,
      :cont_user_id,
      :protocol,
      :preffered_protocol,
      :deployment_type,
      :dependant_on,
      :hostname,
      :domain_name,
      :conf_self_start,
      :large_temp

    attr_accessor :restart_policy,
      :volumes,
      :volumes_from,
      :command,
      :restart_required,
      :rebuild_required,
      :environments,
      :image_repo,
      :capabilities,
      :conf_register_dns


    # for ManagedEngine
    attr_reader  :plugins_path,
      :extract_plugins,
      :web_root

    # for ManagedService
    attr_reader :persistent,
      :type_path,
      :publisher_namespace

    def container
      @container ||= _container
    end

    private

    def _container
      c = case ctype
      when 'service'
        ManagedService.new
      when 'app'
        ManagedEngine.new
      when 'system_service'
        SystemService.new
      when 'utility'
        ManagedUtility.new
      else
        #FIX ME! RAISE SOMETHING
      end
      c.memento = self
      c
    end
  end
end
