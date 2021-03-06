class EngineBuilder < ErrorsApi
  def create_engine_container
    log_build_output('Creating Deploy Image')
    @container = create_managed_container
    raise EngineBuilderException.new(error_hash('Failed to create Managed Container')) unless @container.is_a?(Container::ManagedEngine)
    core.trigger_install_event(@build_params[:engine_name], 'installed')
    service_builder.create_non_persistent_services(@blueprint_reader.services)
    @container
  end

  def create_managed_container
    log_build_output('Creating ManagedEngine')
    @build_params[:web_port] = @web_port
    @build_params[:volumes] = service_builder.volumes
    @build_params[:service_builder] = true
    @build_params[:cont_user_id] = @cont_user_id
    @container = Container::ManagedEngine.new(@build_params, @blueprint_reader)
    @container.save_state # no running.yaml throws a no such container so save so others can use
    @container.save_blueprint(@blueprint)
    log_build_output('Launching ' + @container.to_s)
    ContainerStateFiles.init_engine_dirs(@build_params[:engine_name])
    flag_restart_required(@container) if @has_post_install == true
    launch_deploy(@container)
    # log_build_output('Applying Volume settings and Log Permissions' + @container.to_s)
    #  log_build_errors('Error Failed to Apply FS' + @container.to_s) unless service_builder.run_volume_builder(@container, @web_user)
    @container
  end

  private

  def launch_deploy(managed_container)
    log_build_output('Launching Engine')
    save_engine_built_configuration(managed_container)
    thr = managed_container.create_container
    thr.join
    raise EngineBuilderException.new(error_hash('Failed to create Engine container from Image')) unless managed_container.has_container?
  end

end
