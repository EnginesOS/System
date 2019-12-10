require_relative 'store'

module Container
  class Memento
    class << self
      def from_yaml(yaml)
        STDERR.puts "MEMY" * 15
        YAML::load(yaml)
      rescue StandardError => e
        STDERR.puts('Problem ' + e.to_s)
        STDERR.puts('With: ' + yaml.to_s)
        raise e
      end

      def from_hash(params)
        STDERR.puts "MEM" * 15
        STDERR.puts("Momento from Hash #{params}")
        m = self.new
        all_attrs.each { |a| m.instance_variable_set("@#{a}", params[a]) }
        m
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
          :state,
          :last_error,
          :last_result,
          :arguments,
          :stop_reason,
          :exit_code,
          :has_run,
          :id,
          :state,
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
          :volumes_from,
          :restart_required,
          :rebuild_required,
          :environments,
          :image_repo,
          :capabilities,
          :conf_register_dns,
          :plugins_path,
          :extract_plugins,
          :web_root,
          :persistent,
          :type_path,
          :publisher_namespace,
          :commands,
          :command,
          :out_of_memory,
          :restart_required,
          :conf_zero_conf,
          :consumer_less,
          :deployment_type,
          :out_of_memory,
          :had_out_memory,
          :created,
          :task_queue,
          :last_task,
          :steps,
          :kerberos,
          :stopped_ok,
          :set_state,
          :no_cert_map,
          :permission_as

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
          :publisher_namespace,
          :system_keys,
          :soft_service,
          :aliases,
          :privileged,
          :host_network
        ]
      end

      def managed_utility_attrs
        @managed_utility_attrs ||= [
          :commands,
          :command
        ]
      end
    end

    attr_accessor *all_attrs

    attr_accessor :set_state

    def savable_objs
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

    def to_h
      {}.tap do |r|
        self.class.all_attrs.map do |a|
          r[a] = method(a).call
        end
        STDERR.puts("ENVIONMENTS #{environments}")
        unless environments.nil?
          unless r.is_a?(Hash)
            r[:environments] = environments.map { | v| v.to_h }
          end
        end
        r[:docker_info] = container.docker_info
      end
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
        STDERR.puts("Invalid ctype #{ctype}")
        #FIX ME! RAISE SOMETHING
      end
      c.memento = self
      STDERR.puts("Loaded #{c.container_name} of Type #{c.ctype} via #{ctype}")
      STDERR.puts("Momeneto commands #{commands} \n Container Commands #{c.commands}") if ctype == 'utility'
      c
    end

  end
end
