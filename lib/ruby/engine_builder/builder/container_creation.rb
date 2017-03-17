module ContainerCreation
  def create_engine_container
    log_build_output('Creating Deploy Image')
    @container = create_managed_container
    unless @container.is_a?(ManagedEngine)
      log_build_errors('Failed to create Managed Container')
      return post_failed_build_clean_up
    end
    @service_builder.create_non_persistent_services(@blueprint_reader.services)
    true
  rescue StandardError => e
    abort_build
  end

  def create_managed_container
    log_build_output('Creating ManagedEngine')
    @build_params[:web_port] = @web_port
    @build_params[:volumes] = @service_builder.volumes
    @container = ManagedEngine.new(@build_params, @blueprint_reader, @core_api.container_api)
    @container.save_state # no running.yaml throws a no such container so save so others can use
    log_build_errors('Failed to save blueprint ' + @blueprint.to_s) unless @container.save_blueprint(@blueprint)
    log_build_output('Launching ' + @container.to_s)
    @core_api.init_engine_dirs(@build_params[:engine_name])
    flag_restart_required(@container) if @has_post_install == true
    return log_build_errors('Error Failed to Launch') unless launch_deploy(@container)
    log_build_output('Applying Volume settings and Log Permissions' + @container.to_s)
    return log_build_errors('Error Failed to Apply FS' + @container.to_s) unless @service_builder.run_volume_builder(@container, @web_user)  
    @container
  rescue StandardError => e
    log_exception(e)
    abort_build
  end

  private

  def launch_deploy(managed_container)
    log_build_output('Launching Engine')
    r = managed_container.create_container
    if managed_container.read_state == 'nocontainer'
      log_build_output('Failed to create Engine container from Image')
      return log_error_mesg(' Failed to create Engine container from Image')
    end
    return log_error_mesg('Failed to Launch ', @container) if @container.is_a?(EnginesError)
    save_engine_built_configuration(managed_container)
    return r
  rescue StandardError => e
    log_exception(e)
    abort_build
  end

end