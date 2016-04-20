module EnginesOperations
  require_relative 'service_manager_access.rb'
  #@return boolean indicating sucess
  #@params [Hash] :engine_name
  #Retrieves all persistent service registered to :engine_name and destroys the underlying service (fs db etc)
  # They are removed from the tree if delete is sucessful
  def delete_engine(params)
    SystemDebug.debug(SystemDebug.containers,:delete_engines,params)
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
   if reinstall == true 
     return service_manager.remove_engine_from_managed_engines_registry(params) if service_manager.rm_remove_engine_services(params)
     return log_error_mesg('Failed to remove Engine from engines registry ' +  service_manager.last_error.to_s,params)
#     
    end 
    
#    if reinstall == true
#      return service_manager.remove_engine_from_managed_engines_registry(params) if service_manager.rm_remove_engine_services(params) #remove_engine_from_managed_engines_registry(params)
#      return log_error_mesg('Failed to remove Engine from engines registry ' +  service_manager.last_error.to_s,params)
#    end
    engine.delete_image if engine.has_image? == true 

      SystemDebug.debug(SystemDebug.containers,:engine_image_deleted,engine)
    if service_manager.rm_remove_engine_services(params) #remove_engine_from_managed_engines_registry(params)
      return  engine.delete_engine if service_manager.remove_engine_from_managed_engines_registry(params)
      log_error_mesg('Failed to remove Engine from engines registry ' +  service_manager.last_error.to_s,params)
    end
    log_error_mesg('Failed to rm_remove_engine_services',params)
   

  end

  def delete_image_dependancies(params)
    params[:parent_engine] = params[:engine_name]
    params[:container_type] = 'container'
    SystemDebug.debug(SystemDebug.containers,  :delete_image_dependancies, params)
    return log_error_mesg('Failed to remove deleted Service',params) unless service_manager.rm_remove_engine_services(params)
    return true
  rescue StandardError => e
    log_exception(e)
  end

  #install from fresh copy of blueprint in repository
  def reinstall_engine(engine)
    clear_error
    engine.destroy_container(true) if engine.has_container?
    params = {}
    params[:engine_name] = engine.container_name
    params[:reinstall] = true
    delete_engine(params)
    builder = BuildController.new(self)
    engine.reinstall_engine(builder)

  rescue  StandardError => e
    @last_error = e.to_s
    log_exception(e)
  end

  def set_engine_runtime_properties(params)
     p :set_engine_runtime_properties 
     p params
     engine_name = params[:engine_name]
    
    container = loadManagedEngine(engine_name)
     if container.is_a?(FalseClass)
       return false
     end
    set_container_runtime_properties(container,params)
  end
  
  def set_container_runtime_properties(container,params)
     
    if container.is_active?
      @last_error = 'Container is active'
      p 'Error Container is active'
      return false
    end
    if params.key?(:memory)
      if params[:memory] == container.memory
        @last_error = 'No Change in Memory Value'
        p 'Error o Change in Memory Value'
        return false
      end
      if container.update_memory(params[:memory]) == false
        @last_error = container.last_error
        return false
      end
    end
    if params.key?(:environment_variables)
      new_variables = params[:environment_variables]
     
      container.environments.each do |env|
#         new_variables.each do |new_env|
               new_variables.each_pair do |new_env_name, new_env_value|
                 container.update_environment(new_env_name, new_env_value)
               end
     end
#          if  env.name == new_env_name
#            return log_error_mesg('Cannot Change Value of',env) if env.immutable
#            env.value = new_env_value
#          end
#          # end
#        end
#      end
    end
    if container.has_container?
      return log_error_mesg(container.last_error,container) if !container.destroy_container
      p :destroyed
    end
    return log_error_mesg(container.last_error,container) if !container.create_container
    p :created
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def set_engine_network_properties(container, params)
    set_container_network_properties(container, params)
  end
  def set_container_network_properties(container, params)
     p :set_engine_network_properties
     
     @system_api.set_engine_network_properties(container,params)
   end

end