module ManagedServiceOnAction
  def on_start(event_hash)
    SystemDebug.debug(SystemDebug.container_events,:ON_start_MS,event_hash)
    super
    wait_for_startup
    service_configurations = @container_api.get_pending_service_configurations_hashes({service_name: @container_name, publisher_namespace: @publisher_namespace, type_path: @type_path })
    if service_configurations.is_a?(Array)
      service_configurations.each do |configuration|
        @container_api.update_service_configuration(configuration)
      end
    end
    reregister_consumers
    SystemDebug.debug(SystemDebug.container_events,:ON_start_complete_MS,event_hash)
  rescue StandardError => e
    log_exception(e)
  end

  def on_create(event_hash)
    SystemDebug.debug(SystemDebug.container_events,:ON_Create_MS,event_hash)
    super

    @container_api.load_and_attach_post_services(self)
    service_configurations = @container_api.get_service_configurations_hashes({service_name: @container_name, publisher_namespace: @publisher_namespace, type_path: @type_path})
    if service_configurations.is_a?(Array)
      service_configurations.each do |configuration|
        next if configuration[:no_save] == true
        run_configurator(configuration)
      end
    end

    reregister_consumers
    SystemDebug.debug(SystemDebug.container_events,:ON_Create_MS_compl,event_hash)
  rescue StandardError => e
    log_exception(e)
  end

  def wait_for_startup
    n=0
    while n < 20
      n = n + 1
      sleep(0.5) unless is_startup_complete?
      STDERR.puts('n ' + n.to_s)
    end
  end
  
  def on_stop(what)
    super
  end

  def out_of_mem(what)
    super
  end

end