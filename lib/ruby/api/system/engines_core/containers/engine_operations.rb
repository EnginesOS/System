module EnginesOperations
  #require_relative 'service_manager_access.rb'
  # @return boolean indicating sucess
  # @params [Hash] :engine_name
  #Retrieves all persistent service registered to :engine_name and destroys the underlying service (fs db etc)
  # They are removed from the tree if delete is sucessful
  def delete_engine( params )

    SystemDebug.debug(SystemDebug.containers, :delete_engines, params)
    params[:container_type] = 'container' # Force This
    engine_name = params[:engine_name]
    reinstall = false
    reinstall = params[:reinstall] = true if params.key?(:reinstall)
    if loadManagedEngine(engine_name).has_container?
      raise EnginesException.new(error_hash('Container Exists Please Destroy engine first' , params)) unless reinstall.is_a?(TrueClass)
    end
    remove_engine(engine_name, reinstall, params[:remove_all_data])
  end

  #install from fresh copy of blueprint in repository
  def reinstall_engine(engine)
    clear_error
    r =   engine.destroy_container(true) if engine.has_container?
    params = {
      engine_name: engine.container_name,
      reinstall: true
    }
    delete_engine(params)
    builder = BuildController.new(self)
    @build_thread = Thread.new {
      engine.reinstall_engine(builder)
    }
    return true if @build_thread.alive?
    raise EnginesException.new(error_hash(params[:engine_name], 'Build Failed to start'))
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