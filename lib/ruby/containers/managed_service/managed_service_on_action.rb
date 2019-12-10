module ManagedServiceOnAction
  def on_start(event_hash)
    self.stop_reason = nil
    #   SystemDebug.debug(SystemDebug.container_events, :ON_start_MS, event_hash)
    container_mutex.synchronize {
      set_running_user
      self.stop_reason = nil
      self.exit_code = 0
      STDERR.puts('ONSTART_CALLED' + container_name.to_s + ';' + event_hash.to_s)
      # SystemDebug.debug(SystemDebug.container_events, :ONSTART_CALLED, event_hash)
      self.out_of_memory = false
      # MUst register post each start as IP Changes (different post reboot)
      register_with_dns
      if consumer_less
        self.has_run = true
      else
        if has_run == false
          add_wap_service if deployment_type == 'web'
        end
        self.has_run = true
        begin
          container_dock.register_non_persistent_services(self)
        rescue
          return on_stop(nil) unless is_running?
        end
      end
      save_state
      container_dock.register_ports(container_name, mapped_ports) if mapped_ports.is_a?(Hash)
      #}
      service_configurations = container_dock.pending_service_configurations_hashes({service_name: container_name, publisher_namespace: publisher_namespace, type_path: type_path })
      if service_configurations.is_a?(Array) || registered_consumers.is_a?(Array)
        if wait_for_startup(30)
          if service_configurations.is_a?(Array) && ! service_configurations.empty?
            service_configurations.each do |configuration|
              begin
                #      STDERR.puts('SERVICE CONFIGURATION' + configuration.to_s)
                container_dock.update_service_configuration(configuration)
              rescue
                return on_stop(nil) unless is_running?
              end
            end
          end
          reregister_consumers
        else
          #FIXME schedule this to happen
          STDERR.puts('SERVICE FAILED To STARTUP ' + container_name)
        end
      end
      created_and_started if created == true
    }
    # SystemDebug.debug(SystemDebug.container_events, :ON_start_complete_MS, event_hash)
  end

  def created_and_started
    container_dock.load_and_attach_post_services(self)
    service_configurations = container_dock.retrieve_service_configurations({service_name: container_name, publisher_namespace: publisher_namespace, type_path: type_path})
    if service_configurations.is_a?(Array)
      service_configurations.each do |configuration|
        next if configuration[:no_save] == true
        run_configurator(configuration) unless configuration[:variables].nil?
      end
    end
    #   SystemDebug.debug(SystemDebug.container_events, :ON_StartCreate_MS_compl)
    self.created = false
  end

  def on_stop(what, ec = 0)
    container_mutex.synchronize {
      self.exit_code = ec
      # SystemDebug.debug(SystemDebug.container_events, :ONStop_CALLED, what)
      self.stop_reason = what if stop_reason.nil?
      if what == 'die'
        self.had_out_memory = out_of_memory
        self.out_of_memory = false
        save_state
        #return true if consumer_less
        # deregister_with_dns # Really its in the following nowMUst register each time as IP Changes
        container_dock.deregister_non_persistent_services(self)
        container_dock.deregister_ports(container_name, mapped_ports) if mapped_ports.is_a?(Hash)
      end
    }
  end

  def out_of_mem(what)
    container_mutex.synchronize {
      #   SystemDebug.debug(SystemDebug.container_events, :OUTOF_MEM_CALLED, what)
      self.out_of_memory = true
      self.had_out_memory = true
      save_state
    }
  end

end