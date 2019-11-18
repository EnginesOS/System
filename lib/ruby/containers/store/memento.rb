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
          :stop_reason
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
          :conf_register_dns,
          :plugins_path,
          :extract_plugins,
          :web_root,
          :persistent,
          :type_path,
          :publisher_namespace,
          :commands,
          :command,
          :id,
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
          :set_state
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
          :system_keys
        ]
      end

      def managed_utility_attrs
        @managed_utility_attrs ||= [
          :commands,
          :command
        ]
      end
    end

    #attr_accessor all_attrs
    attr_accessor    :framework, # used in build also in env
    :runtime, #from BP used in env
    :repository, #BP location
    :deployment_type, #from BP web or not
    :data_uid,  #set at engine install
    :data_gid, #set at engine install
    :cont_user_id, #set at engine install
    :hostname, # web site url prefs for sw not limited to only web sites
    :domain_name, # web site url prefs for sw not limited to only web sites
    :conf_zero_conf, #editable start time
    :conf_register_dns, #editable start time option
    :protocol, # web site url prefs for sw start time
    :preffered_protocol, # web site url prefs for sw start time
    :web_port, #web site url set in bp can be modified (only change for debug)   start time
    :web_root,# web site start time
    :restart_required, #triggered by the install script actual store is a dir common to engines and engines system
    :rebuild_required, # Tech speak for needs update
    :plugins_path, #app set in bp to be used in runtim
    :extract_plugins,#app set in bp to be used in runtim
    :conf_self_start, #um #create time
    :privileged, #set in BP fixed   fined in BP
    :kerberos, #set in BP Fix
    :capabilities, # create time option defined in BP
    :kerberos, #set in BP Fix create time
    :system_keys, #set in BP create time
    :no_cert_map, #set in BP create time
    :image_repo, # where the image is, inferred in engines docker hub repo for services
    :large_temp, #engine create time option
    :restart_policy, #runtime currently fixed create time option
    :image, # name of in image repo create time option
    :mapped_ports, #create time option for engines
    :ctype, #service or app or .. Fixed in BP
    :container_name, #fixed at install for apps, fixed for services
    :memory, # runtime
    :id, #runtime create time will change over life of engine
    :out_of_memory, #runtime Currently has oom error
    :had_out_memory, #runtime has recovered (or restarted) from oom can be cleared and is cleared on recreate
    :created, #runtime set on first stop
    :state, #runtime
    :stopped_ok, #runtime Dont start if stopped
    :stop_reason, #runtime died|killed|OOM|..
    :set_state, #run time option what it is set to
    :last_error, #run time place for last error
    :last_result, #run time place for last result
    :environments, #array mixture of system/ frawework and bp defined
    :persistent, #servics only fixed
    :type_path, #servics only fixed
    :host_network, #servics only fixed
    :soft_service,#servics only fixed
    :aliases,#servics only fixed
    :publisher_namespace, #servics only fixed
    :consumer_less, #services only
    :dependant_on, #services only
    :volumes, #Services only set at install time used at create time (will move most to registry)
    :commands, #utilities fixed in BP
    :command, #utilies set and used at create time
    :volumes_from, #Utilities set and used at create time
    :arguments, #utilties use for args to startup command may not just be limited to utilites
    :task_queue, #runtime
    :steps, #runtime
    :last_task #runtime

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
