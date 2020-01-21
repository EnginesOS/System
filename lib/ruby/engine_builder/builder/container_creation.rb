module ContainerCreation
  def create_engine_container
    log_build_output('Creating Deploy Image')
    @container = create_managed_container
    raise EngineBuilderException.new(error_hash('Failed to create Managed Container')) unless @container.is_a?(Container::ManagedEngine)
    raise EngineBuilderException.new(error_hash('Failed to create Engine container from Image')) unless @container.has_container?
      STDERR.puts('ADDing NON PERSIST')
    service_builder.create_non_persistent_services(@blueprint_reader.services)
  end

  def create_managed_container
    log_build_output('Creating ManagedEngine')
    memento.web_port = @web_port
    memento.ctype = 'app'
    memento.volumes = service_builder.volumes
    memento.cont_user_id = @cont_user_id
    memento.deployment_type = @blueprint_reader.deployment_type
    memento.conf_register_dns = true
    STDERR.puts(" Memento #{memento.to_h}")
    @container = memento.container
    @container.volume_service_builder = true
   # @container.apply_build_params(memento, @blueprint_reader)
    @container.store.init_engine_dirs(memento.container_name)
    @container.save_blueprint(@blueprint)
    log_build_output('Launching ' + @container.to_s)
    flag_restart_required(@container) if @has_post_install == true
    launch_deploy(@container)
    @container
  end

  protected

  def event_handler
     @event_handler ||= EventHandler.instance
  end

  def launch_deploy(managed_container)
    log_build_output('Launching Engine')
    save_engine_built_configuration(managed_container)
    thr = managed_container.create_container
    thr.join
    @result_mesg = 'Complete'    
  end

end
