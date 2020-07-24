class EnginesCore
  def lookup_app_uid(container_name)
    engine = loadManagedEngine(container_name)
    engine.cont_user_id
  end

  def lookup_app_duid(container_name)
    engine = loadManagedEngine(container_name)
    engine.data_uid
  end

  def lookup_app_dgid(container_name)
    engine = loadManagedEngine(container_name)
    engine.data_gid
  end

  # @return boolean indicating sucess
  # @params [Hash] :engine_name
  #Retrieves all persistent service registered to :engine_name and destroys the underlying service (fs db etc)
  # They are removed from the tree if delete is sucessful
  def delete_engine_and_services(params)
    #STDERR.puts('delete_engine_and_services ' + params.to_s)
    # SystemDebug.debug(SystemDebug.containers, :delete_engines, params)

    params[:container_type] = 'app' # Force This
    params[:parent_engine] = params[:engine_name]
    begin
      engine = loadManagedEngine(params[:engine_name])
      system_api.trigger_engine_event(engine, 'uninstalling', 'uninstall')
      #Following is for the roll back of a failed build
    rescue StandardError => e
      unless params[:rollback] == true
        system_api.trigger_engine_event(engine, 'failed', 'uninstall')
        raise e
      end
    end
    if params[:rollback] == true
      # STDERR.puts(' Roll back called' + params.to_s )
      begin
        unless remove_engine_services(params)
          system_api.trigger_engine_event(engine, 'failed', 'uninstall')
          raise EnginesException.new(error_hash('Failed to remove engine services', params))
        end
        true
      end
    else
      if engine.has_container?
        system_api.trigger_engine_event(engine, 'failed', 'uninstall')
        raise EnginesException.new(error_hash('Container Exists Please Destroy engine first' , params)) unless params[:reinstall] .is_a?(TrueClass)
      end
      remove_engine_services(params) #engine_name, reinstall, params[:remove_all_data])
      engine.delete_image if engine.has_image? == true
      system_api.trigger_engine_event(engine, 'success', 'uninstall') unless params[:reinstall] == true
      engine.delete_engine unless params[:reinstall] == true
    end
  rescue Exception => e
    system_api.trigger_engine_event(engine, 'failed', 'uninstall') unless engine.nil?
    raise e
  end

  #install from fresh copy of blueprint in repository
  def reinstall_engine(engine)
    r = false
    system_api.trigger_engine_event(engine, 'reinstalling', 'reinstall')
    if engine.has_container?
      engine.destroy_container(true)
      engine.wait_for('destroy', 30)
    end

    params = {
      engine_name: engine.container_name,
      reinstall: true
    }
    @build_thread = Thread.new { engine.reinstall_engine }
    @build_thread[:name] = 'reinstall engine'
    unless @build_thread.alive?
      system_api.trigger_engine_event(engine, 'fail', 'reinstall')
  
      raise EnginesException.new(error_hash(params[:engine_name], 'Build Failed to start'))
    else
      r = true
    end
    r
  rescue StandardError => e
    system_api.trigger_engine_event(engine, 'fail', 'reinstall')
    SystemUtils.log_exception(e, 'reinstall_engine:' + params)
    thr.exit unless thr.nil?
  end

  #install from fresh copy of blueprint in repository
  def restore_engine(engine)
    engine.destroy_container(true) if engine.has_container?
    params = {
      engine_name: engine.container_name,
      reinstall: true,
      restore: true
    }
    delete_engine_and_services(params)
    @build_thread = Thread.new { engine.restore_engine }
    #  STDERR.puts('Restore started on '  + engine.container_name.to_s)
    @build_thread[:name] = 'restore engine'
    unless @build_thread.alive?
      raise EnginesException.new(error_hash(params[:engine_name], 'Build Failed to start'))
    end
    @build_thread
  rescue StandardError =>e
    STDERR.puts('Build Thread Excepted ' + e.to_s + "\n" + e.backtrace.to_s)
  end

  def set_container_runtime_properties(container, params)
    # STDERR.puts('set_container_runtime_properties ' +  params.to_s)
    raise EnginesException.new(warning_hash(params[:engine_name],'Container is active')) if container.is_active?
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
    system_api.set_engine_network_properties(container, params)
  end

  def docker_build_engine(engine_name, build_archive_filename, builder)
    docker_api.build_engine(engine_name, build_archive_filename, builder)
  end

  def clear_lost_engines
    if SystemStatus.is_building?
      []
    else
      r = []
      engines_tree = service_manager.managed_engines_registry[:children]
      engines = nil
      engines_tree.each do |node|
        if node[:name] == 'Application'
          engines = node
          break
        end
      end
      unless engines.nil?
        if engines[:children].is_a?(Array)
          engines[:children].each do |engine_node|
            name = engine_node[:name]
            next if name == 'system' || name == 'registry' || name == 'utility' #avoided a past bug
            begin
              t = loadManagedEngine(name)
            rescue
              r.push(name)
              begin
                remove_engine_services(
                {lost: true, container_type: 'app', remove_all_data: 'none', parent_engine: name})
              rescue StandardError =>e
              end
              # here find services on engine but not on service
              services = get_engine_persistent_services({ parent_engine: name})
              #        STDERR.puts(' remove_service_from_engine_only ' +services.to_s)
              services.each do |service|
                begin
                  #    STDERR.puts(' remove_service_from_engine_only ' + service.to_s )
                  service_manager.remove_service_from_engine_only(service)
                rescue
                  next
                end
              end
            end
          end
        end
      end
      r
    end
  end


  private

  def remove_engine_services(params)
    #SystemDebug.debug(SystemDebug.containers, :delete_engines, params)
    params[:container_type] = 'app'
    params[:no_exceptions] = true
    begin
      service_manager.remove_managed_persistent_services(params)
    rescue EnginesException => e
      STDERR.puts('Except  ' + e.to_s)
      raise e unless e.is_a_warning?
      STDERR.puts('WarnINGES  ' + e.to_s)
    end
    begin
      service_manager.remove_engine_non_persistent_services(params)
    rescue EnginesException => e
      raise e unless e.is_a_warning?
    end
  end
end
