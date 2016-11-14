module EnginesOperations
  require_relative 'service_manager_access.rb'
  #@return boolean indicating sucess
  #@params [Hash] :engine_name
  #Retrieves all persistent service registered to :engine_name and destroys the underlying service (fs db etc)
  # They are removed from the tree if delete is sucessful
  def delete_engine(params)
    r = ''
    SystemDebug.debug(SystemDebug.containers,:delete_engines,params)
    # return log_error_mesg('Failed to remove engine as has container ',params) if
    params[:container_type] = 'container' # Force This
    return r if (r = delete_image_dependancies(params) ).is_a?(EnginesError)
    engine_name = params[:engine_name]
    reinstall = false
    reinstall = params[:reinstall] = true if params.key?(:reinstall)
    return remove_engine(engine_name, reinstall)
  end

  def remove_engine(engine_name, reinstall = false)
    r = ''
    engine = loadManagedEngine(engine_name)
    SystemDebug.debug(SystemDebug.containers,:delete_engines,engine_name,engine, :resinstall,reinstall)
    params = {}
    params[:engine_name] = engine_name
    params[:container_type] = 'container' # Force This
    params[:parent_engine] =  engine_name
    params[:reinstall] = reinstall
    unless engine.is_a?(ManagedEngine) # used in roll back and only works if no engine do mess with this logic
      return true if service_manager.remove_engine_from_managed_engines_registry(params)
      return log_error_mesg('Failed to find Engine',params)
    end

    engine.delete_image if engine.has_image? == true

    SystemDebug.debug(SystemDebug.containers,:engine_image_deleted,engine)
    unless(r = service_manager.rm_remove_engine_services(params)).is_a?(EnginesError) #remove_engine_from_managed_engines_registry(params)
      return r if ( r = service_manager.remove_engine_from_managed_engines_registry(params)).is_a?(EnginesError)
      return r if reinstall == true
      return engine.delete_engine
    end
    return r
  end

  def delete_image_dependancies(params)
    r = ''
    params[:parent_engine] = params[:engine_name]
    params[:container_type] = 'container'
    SystemDebug.debug(SystemDebug.containers, :delete_image_dependancies, params)
    return r if (r = service_manager.rm_remove_engine_services(params)).is_a?(EnginesError)
    return true
  rescue StandardError => e
    log_exception(e)
  end

  #install from fresh copy of blueprint in repository
  def reinstall_engine(engine)
    clear_error
    r =   engine.destroy_container(true) if engine.has_container?
    return r if r.is_a?(EnginesError)
    params = {}
    params[:engine_name] = engine.container_name
    params[:reinstall] = true
    delete_engine(params)
    builder = BuildController.new(self)
    @build_thread = Thread.new {
      engine.reinstall_engine(builder)
    }
    return true if @build_thread.alive?
    return log_error(params[:engine_name], 'Build Failed to start')

  rescue  StandardError => e
    log_exception(e)
  end

  def set_container_runtime_properties(container,params)
    if container.is_active?
      return EnginesCoreError.new('Container is active', :warning)
    end
    r = false

    if params.key?(:environment_variables) && ! params[:environment_variables].nil?
      new_variables = params[:environment_variables]

      #   container.environments.each do |env|
      #         new_variables.each do |new_env|
      new_variables.each_pair do |new_env_name, new_env_value|
        r = container.update_environment(new_env_name, new_env_value)
        # return r unless r.is_a?(TrueClass)
      end
    end

    if params.key?(:memory) &&  ! params[:memory].nil?
      if params[:memory] == container.memory
        return r if r.is_a?(TrueClass)
        return EnginesCoreError.new('Error no Change in Memory Value', :warning)
      end
      container.update_memory(params[:memory])
    end
    true

    if container.has_container?
      r = container.destroy_container
      return r unless r == true
    end
    container.create_container

  rescue StandardError => e
    log_exception(e)
  end

  def set_engine_network_properties(container, params)
    set_container_network_properties(container, params)
  end

  def set_container_network_properties(container, params)
    @system_api.set_engine_network_properties(container,params)
  end

  def docker_build_engine(engine_name, build_archive_filename , builder)
    @docker_api.build_engine(engine_name, build_archive_filename, builder)
  end

end