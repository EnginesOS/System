module ManagedServiceOnAction
  def on_start(event_hash)
    @stop_reason = nil
    SystemDebug.debug(SystemDebug.container_events, :ON_start_MS, event_hash)
    @container_mutex.synchronize {
      set_running_user
      @stop_reason = nil
      @exit_code = 0
      #STDERR.puts('ONSTART_CALLED' + container_name.to_s + ';' + event_hash.to_s)
      SystemDebug.debug(SystemDebug.container_events, :ONSTART_CALLED, event_hash)
      @out_of_memory = false
      # MUst register post each start as IP Changes (different post reboot)
      register_with_dns
      if @consumer_less
        @has_run = true
      else
        if  @has_run == false
          add_wap_service if @deployment_type == 'web'
        end
        @has_run = true
        save_state
        begin
          @container_api.register_non_persistent_services(self)
        rescue
          return on_stop(nil) unless is_running?
        end
      end
      save_state
      @container_api.register_ports(@container_name, @mapped_ports) if @mapped_ports.is_a?(Hash)
    }
    service_configurations = @container_api.pending_service_configurations_hashes({service_name: @container_name, publisher_namespace: @publisher_namespace, type_path: @type_path })
    if service_configurations.is_a?(Array) || registered_consumers.is_a?(Array)
      if wait_for_startup
        if service_configurations.is_a?(Array) && ! service_configurations.empty?
          service_configurations.each do |configuration|
            begin
              STDERR.puts('SERVICE CONFIGURATION' + configuration.to_s)
              @container_api.update_service_configuration(configuration)
            rescue
              return on_stop(nil) unless is_running?
            end
          end
        end
        reregister_consumers
      else
        STDERR.puts('SERVICE FAILED To STARTUP ' + @container_name)
      end
    end
    created_and_started if @created == true
    SystemDebug.debug(SystemDebug.container_events, :ON_start_complete_MS, event_hash)
  end

  def created_and_started
    @container_api.load_and_attach_post_services(self)
    service_configurations = @container_api.retrieve_service_configurations({service_name: @container_name, publisher_namespace: @publisher_namespace, type_path: @type_path})
    if service_configurations.is_a?(Array)
      service_configurations.each do |configuration|
        next if configuration[:no_save] == true
        run_configurator(configuration) unless configuration[:variables].nil?
      end
    end
    SystemDebug.debug(SystemDebug.container_events, :ON_StartCreate_MS_compl)
    @created = false
  end

#  def on_create(event_hash)
#    SystemDebug.debug(SystemDebug.container_events, :ON_Create_MS,event_hash)
#    @container_mutex.synchronize {
#      SystemDebug.debug(SystemDebug.container_events, :ON_Create_CALLED,event_hash)
#      @container_id = event_hash[:id]
#      @out_of_memory = false
#      @had_out_memory = false
#      @has_run = false
#      @container_api.apply_schedules(self)
#      @created = true
#      save_state
#      SystemDebug.debug(SystemDebug.container_events, :ON_Create_Finised, event_hash)
#    }
#    start_container
#  end

  def on_stop(what, exit_code = 0)
    @exit_code = exit_code
    SystemDebug.debug(SystemDebug.container_events, :ONStop_CALLED, what)
    @stop_reason = what if @stop_reason.nil?
    if what == 'die'
      @had_out_memory = @out_of_memory
      @out_of_memory = false
      save_state
      #return true if @consumer_less
      # deregister_with_dns # Really its in the following nowMUst register each time as IP Changes
      @container_api.deregister_non_persistent_services(self)
      @container_api.deregister_ports(@container_name, @mapped_ports) if @mapped_ports.is_a?(Hash)
    end
  end

  def out_of_mem(what)
    SystemDebug.debug(SystemDebug.container_events, :OUTOF_MEM_CALLED, what)
    @out_of_memory = true
    @had_out_memory = true
    save_state
  end

end