module EnginesOperations
  require_relative 'service_manager_access.rb'
  #@return boolean indicating sucess
  #@params [Hash] :engine_name
  #Retrieves all persistent service registered to :engine_name and destroys the underlying service (fs db etc)
  # They are removed from the tree if delete is sucessful
  def delete_engine(params)
   # return log_error_mesg('Failed to remove engine as has container ',params) if 
    params[:container_type] = 'container' # Force This
    return log_error_mesg('Failed to remove engine Services',params) unless delete_image_dependancies(params)
    engine_name = params[:engine_name]
    reinstall = false
    reinstall = params[:reinstall] = true if params.key?(:reinstall)
    remove_engine(engine_name, reinstall)
    return true
  end

  def remove_engine(engine_name, reinstall = false)
    engine = loadManagedEngine(engine_name)
    params = {}
    params[:engine_name] = engine_name
    params[:container_type] = 'container' # Force This
    params[:parent_engine] =  engine_name
    unless engine.is_a?(ManagedEngine) # used in roll back and only works if no engine do mess with this logic
      return true if service_manager.remove_engine_from_managed_engines_registry(params)
      return log_error_mesg('Failed to find Engine',params)
    end
    if reinstall == true 
     return service_manager.remove_engine_from_managed_engines_registry(params) if service_manager.rm_remove_engine_services(params)
     return log_error_mesg('Failed to remove Engine from engines registry ' +  service_manager.last_error.to_s,params)
    end 
    
    if reinstall == true
      return service_manager.remove_engine_from_managed_engines_registry(params) if service_manager.rm_remove_engine_services(params) #remove_engine_from_managed_engines_registry(params)
      return log_error_mesg('Failed to remove Engine from engines registry ' +  service_manager.last_error.to_s,params)
    end
    
    if engine.delete_image || engine.has_image? == false
      p :engine_image_deleted
      return service_manager.remove_engine_from_managed_engines_registry(params) if service_manager.rm_remove_engine_services(params) #remove_engine_from_managed_engines_registry(params)
      return log_error_mesg('Failed to remove Engine from engines registry ' +  service_manager.last_error.to_s,params)
    end
    log_error_mesg('Failed to delete image',params)
  end

  def delete_image_dependancies(params)
    params[:parent_engine] = params[:engine_name]
    params[:container_type] = 'container'
    p :delete_image_dependancies
    p params
    return log_error_mesg('Failed to remove deleted Service',params) unless service_manager.rm_remove_engine_services(params)
    return true
  rescue StandardError => e
    log_exception(e)
  end

  #install from fresh copy of blueprint in repository
  def reinstall_engine(engine)
    clear_error
    engine.destroy_container if engine.has_container?
    params = {}
    params[:engine_name] = engine.container_name
    delete_engine(params)
    builder = BuildController.new(self)
    builder.reinstall_engine(engine)
  rescue  StandardError => e
    @last_error = e.to_s
    log_exception(e)
  end

  def set_engine_runtime_properties(params)
    engine_name = params[:engine_name]
    engine = loadManagedEngine(engine_name)
    if engine.is_a?(EnginesOSapiResult)
      @last_error = engine.result_mesg
      return false
    end
    if engine.is_active?
      @last_error = 'Container is active'
      return false
    end
    if params.key?(:memory)
      if params[:memory] == engine.memory
        @last_error = 'No Change in Memory Value'
        return false
      end
      if engine.update_memory(params[:memory]) == false
        @last_error = engine.last_error
        return false
      end
    end
    if params.key?(:environment_variables)
      new_variables = params[:environment_variables]
      engine.environments.each do |env|
        # new_variables.each do |new_env|
        new_variables.each_pair do |new_env_name, new_env_value|
          if  env.name == new_env_name
            return log_error_mesg('Cannot Change Value of',env) if env.immutable
            env.value = new_env_value
          end
          # end
        end
      end
    end
    if engine.has_container?
      return log_error_mesg(engine.last_error,engine) if !engine.destroy_container
    end
    return log_error_mesg(engine.last_error,engine) if !engine.create_container
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def set_engine_network_properties (engine, params)
    test_system_api_result(@system_api.set_engine_network_properties(engine,params))
  end

end