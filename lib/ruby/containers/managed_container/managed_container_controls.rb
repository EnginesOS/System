module ManagedContainerControls
  def destroy_container
    return false unless has_api?
    clear_error
    in_progress(:destroy) # this represents the state we want and not necessarily the one we get
    return task_complete if super
    task_failed('destroy')
  end

  def setup_container
    clear_error
    return false unless has_api?
    ret_val = false
    state = read_state
    in_progress(:stop)
    unless has_container?
      ret_val = @container_api.setup_container(self)
      expire_engine_info
    else
      task_failed('setup')
      log_error_mesg('Cannot create container as container exists ',state)
    end
    return task_complete if ret_val
    task_failed('setup')
  end

  def create_container
    clear_error
    return false unless has_api?
    in_progress(:create)
    return task_failed('create') unless super
    state = read_state
    return log_error_mesg('No longer running ' + state + ':' + @setState, self) unless state == 'running'
    register_with_dns # MUst register each time as IP Changes
    add_nginx_service if @deployment_type == 'web'
    @container_api.register_non_persistant_services(self)
    task_complete
  rescue StandardError => e
    log_exception(e)
  end

  def recreate_container
    ret_val = false
    in_progress(:recreate)
    return task_failed('destroy/recreate') unless destroy_container
    return task_failed('create/rcreate') unless create_container
    task_complete
  end

  def unpause_container
    clear_error
    return false unless has_api?
    in_progress(:unpause)
    return task_failed('unpause') unless super
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
    task_complete
  end

  def pause_container
    clear_error
    return false unless has_api?
    in_progress(:pause)
    return task_failed('pause') unless super
    @container_api.deregister_non_persistant_services(self)
    task_complete
  end

  def stop_container
    clear_error
    return false unless has_api?
    in_progress(:stop)
    @container_api.deregister_non_persistant_services(self)
    return task_failed('stop') unless super
    task_complete
  end

  def start_container
    clear_error
    return false unless has_api?
    in_progress(:start)
    return task_failed('start') unless super
    @restart_required = false
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
    task_complete
  end

  def restart_container

    in_progress(:restart)
    return task_failed('restart/stop') unless stop_container
    return task_failed('restart/start') unless start_container
    task_complete
  end

  def rebuild_container
    return false unless has_api?
    in_progress(:rebuild)
    ret_val = @container_api.rebuild_image(self)
    expire_engine_info
    if ret_val == true
      register_with_dns # MUst register each time as IP Changes
      #add_nginx_service if @deployment_type == 'web'
      @container_api.register_non_persistant_services(self)
    end
    return task_complete if ret_val
    task_failed('rebuild')
  end
end