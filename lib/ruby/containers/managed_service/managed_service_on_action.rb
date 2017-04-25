module ManagedServiceOnAction
  def on_start(event_hash)
    SystemDebug.debug(SystemDebug.container_events,:ON_start_MS,event_hash)
    @container_mutex.synchronize {
         set_running_user
         STDERR.puts('ONSTART_CALLED' + container_name.to_s + ';' + what.to_s)
         SystemDebug.debug(SystemDebug.container_events,:ONSTART_CALLED, what)
         @out_of_memory = false
         if @consumer_less
           @has_run = true
           return save_state
         end
         # MUst register post each start as IP Changes (different post reboot)
         register_with_dns
         if  @has_run == false
           add_nginx_service if @deployment_type == 'web'
         end
         @has_run = true
         save_state
         begin
         @container_api.register_non_persistent_services(self)
         rescue
          return on_stop(nil) unless is_running?
         end
         save_state
       }
    wait_for_startup
    service_configurations = @container_api.pending_service_configurations_hashes({service_name: @container_name, publisher_namespace: @publisher_namespace, type_path: @type_path })
    if service_configurations.is_a?(Array)
      service_configurations.each do |configuration|
        begin
        @container_api.update_service_configuration(configuration)
        rescue 
          return on_stop(nil) unless is_running?
        end
      end
    end
    created_and_started if @created == true
    reregister_consumers
    SystemDebug.debug(SystemDebug.container_events,:ON_start_complete_MS,event_hash)
  end
  
  def created_and_started
    @container_api.load_and_attach_post_services(self)
        service_configurations = @container_api.retrieve_service_configurations_hashes({service_name: @container_name, publisher_namespace: @publisher_namespace, type_path: @type_path})
        if service_configurations.is_a?(Array)
          service_configurations.each do |configuration|
            next if configuration[:no_save] == true
            run_configurator(configuration)
          end
        end      
        SystemDebug.debug(SystemDebug.container_events,:ON_StartCreate_MS_compl)
        @created = false
  end

  def on_create(event_hash)
    SystemDebug.debug(SystemDebug.container_events,:ON_Create_MS,event_hash)
    @container_mutex.synchronize {
         SystemDebug.debug(SystemDebug.container_events,:ON_Create_CALLED,event_hash)
         @container_id = event_hash[:id]
         @out_of_memory = false
         @had_out_memory = false
         @has_run = false
         @container_api.apply_schedules(self)
         save_state    
         SystemDebug.debug(SystemDebug.container_events, :ON_Create_Finised, event_hash)
       }
       start_container
    @created = true
  end

  def wait_for_startup
    n=0
    while n < 20
      n = n + 1
      sleep(0.5) unless is_startup_complete?
    end
  end
  
  def on_stop(what)
    SystemDebug.debug(SystemDebug.container_events, :ONStop_CALLED, what)
       @had_out_memory = @out_of_memory
       @out_of_memory = false
       save_state
       #return true if @consumer_less    
       # deregister_with_dns # Really its in the following nowMUst register each time as IP Changes
       @container_api.deregister_non_persistent_services(self)
    
  end

  def out_of_mem(what)
    SystemDebug.debug(SystemDebug.container_events, :OUTOF_MEM_CALLED, what)
       @out_of_memory = true
       @had_out_memory = true
       save_state
  end

end