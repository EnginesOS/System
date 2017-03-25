module EnginesOperations
  #require_relative 'service_manager_access.rb'
  # @return boolean indicating sucess
  # @params [Hash] :engine_name
  #Retrieves all persistent service registered to :engine_name and destroys the underlying service (fs db etc)
  # They are removed from the tree if delete is sucessful
  def delete_engine(params)
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
  
  def remove_engine(engine_name, reinstall = false, remove_all_data = 'all')
      engine = loadManagedEngine(engine_name)
      SystemDebug.debug(SystemDebug.containers,:delete_engines,engine_name,engine, :resinstall,reinstall)
      params = {
        engine_name: engine_name,
        container_type: 'container', # Force This
        parent_engine: engine_name,
        reinstall: reinstall,
        remove_all_data: remove_all_data
      }
      STDERR.puts(' Remove engine ' + params.to_s )
      unless engine.is_a?(ManagedEngine) # DO NOT MESS with this logi used in roll back and only works if no engine DO NOT MESS with this logic
        return true if service_manager.remove_engine_from_managed_engine(params)
        raise EnginesException.new(error_hash('Failed to find Engine',params))
      end
  
      #  service_manager.remove_managed_services(params)#remove_engine_from_managed_engines_registry(params)
      begin
        STDERR.puts(' Remove engine calling service_manager.remove_engine_services' + params.to_s )
      service_manager.remove_engine_services(params)
      rescue EnginesException => e
        raise e unless e.is_a_warning?
      end
      engine.delete_image if engine.has_image? == true
      SystemDebug.debug(SystemDebug.containers,:engine_image_deleted,engine)
      return if reinstall == true
      engine.delete_engine
    end

  #install from fresh copy of blueprint in repository
  def reinstall_engine(engine)
    clear_error
    r =  engine.destroy_container(true) if engine.has_container?
    params = {
      engine_name: engine.container_name,
      reinstall: true
    }
    delete_engine(params)
    builder = BuildController.new(self)
    @build_thread = Thread.new { engine.reinstall_engine(builder) }
    return true if @build_thread.alive?
    raise EnginesException.new(error_hash(params[:engine_name], 'Build Failed to start'))
  end

  def set_container_runtime_properties(container,params)
    if container.is_active?
      raise EnginesException.new(error_hash(params[:engine_name],'Container is active'))
    end
    if params.key?(:environment_variables) && ! params[:environment_variables].nil?
      new_variables = params[:environment_variables]
      new_variables.each_pair do |new_env_name, new_env_value|
        container.update_environment(new_env_name, new_env_value)
      end
    end
    container.update_memory(params[:memory]) if params.key?(:memory) && ! params[:memory].nil?
    container.destroy_container if container.has_container?
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