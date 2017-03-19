module ManagedServiceOnAction
  def on_start(event_hash)
    SystemDebug.debug(SystemDebug.container_events,:ON_start_MS,event_hash)
    super
    wait_for_startup
    service_configurations = @container_api.get_pending_service_configurations_hashes({service_name: @container_name, publisher_namespace: @publisher_namespace, type_path: @type_path })
    if service_configurations.is_a?(Array)
      service_configurations.each do |configuration|
        begin
        @container_api.update_service_configuration(configuration)
        rescue 
          return on_stop unless is_running?
        end
      end
    end
    created_and_started if @created == true
    reregister_consumers
    SystemDebug.debug(SystemDebug.container_events,:ON_start_complete_MS,event_hash)
  end
  
  def created_and_started
    @container_api.load_and_attach_post_services(self)
        service_configurations = @container_api.get_service_configurations_hashes({service_name: @container_name, publisher_namespace: @publisher_namespace, type_path: @type_path})
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
    super
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
    super
  end

  def out_of_mem(what)
    super
  end

end