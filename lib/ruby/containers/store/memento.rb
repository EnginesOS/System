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

      def from_hash(params)
        m = self.new
        all_attrs.each { |a| m.instance_variable_set("@#{a}", params[a]) }
      end

      def all_attrs
        container_attrs + managed_container_attrs + managed_engine_attrs + managed_service_attrs + managed_utility_attrs
      end

      def container_attrs
        @container_attrs ||= [
          :ctype,
          :memory,
          :container_name,
          :image,
          :web_port,
          :volumes,
          :mapped_ports,
          :environments,
          :setState,
          :last_error,
          :last_result,
          :arguments
        ]
      end

      def managed_container_attrs
        @managed_container_attrs ||= [
          :framework,
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
          :large_temp,
          :restart_policy,
          :volumes,
          :volumes_from,
          :restart_required,
          :rebuild_required,
          :environments,
          :image_repo,
          :capabilities,
          :conf_register_dns
        ]
      end

      def managed_engine_attrs
        @managed_engine_attrs ||= [
          :plugins_path,
          :extract_plugins,
          :web_root
        ]
      end

      def managed_service_attrs
        @managed_service_attrs ||= [
          :persistent,
          :type_path,
          :publisher_namespace
        ]
      end

      def managed_utility_attrs
        @managed_utility_attrs ||= [
          :commands,
          :command
        ]
      end
    end

    attr_accessor all_attrs

    def savable
      YAML.dump(unsavable_cleared)
    end

    def unsavable_cleared
      dup.tap do |d|
        d.instance_variable_set(:@container, nil)
      end
    end

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

    def unsavable_cleared
      @container = nil
      self
    end
  end
end
