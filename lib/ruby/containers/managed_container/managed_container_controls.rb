module ManagedContainerControls
  def destroy_container

    return false unless has_api?
    return false unless prep_task(:destroy)
    return true if super
    task_failed('destroy')
  end

  def setup_container
    return false unless has_api?
    return false unless prep_task(:create)
    ret_val = false
    unless has_container?
      ret_val = @container_api.setup_container(self)
      expire_engine_info
    else
      task_failed('setup')
      log_error_mesg('Cannot create container as container exists ',state)
    end
    return true if ret_val
    task_failed('setup')
  end

  def create_container
   
    return false unless has_api?
    p :teask_preping
    return false unless prep_task(:create)
    p :teask_preped
    return task_failed('create') unless super
    p :create_suupre_ran
    state = read_state
    return log_error_mesg('No longer running ' + state + ':' + @setState, self) unless state == 'running'
    register_with_dns # MUst register each time as IP Changes
    add_nginx_service if @deployment_type == 'web'
    @container_api.register_non_persistant_services(self)
    true
  rescue StandardError => e
    log_exception(e)
  end

  def recreate_container
   
    return task_failed('destroy/recreate') unless destroy_container
    wait_for_task
    return task_failed('create/recreate') unless create_container
    true
  end

  def unpause_container
    
    return false unless has_api?
    return false unless prep_task(:unpause)
    return task_failed('unpause') unless super
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
    true
  end

  def pause_container
 
    return false unless has_api?
    return false unless prep_task(:pause)
    return task_failed('pause') unless super
    @container_api.deregister_non_persistant_services(self)
    true
  end

  def stop_container
    if read_state == 'nocontainer'
       @setState = 'nocontainer'
       return true
     end
     p :stop_read_sta
     p read_state
    return false unless has_api?
    return false unless prep_task(:stop)
    @container_api.deregister_non_persistant_services(self)
    return task_failed('stop') unless super
    true
  end

  def start_container
   
    return false unless has_api?    
    return false unless prep_task(:start)
    return task_failed('start') unless super
    @restart_required = false
    register_with_dns # MUst register each time as IP Changes
    @container_api.register_non_persistant_services(self)
    true
  end

  def restart_container  
    return task_failed('restart/stop') unless stop_container
    wait_for_task
    return task_failed('restart/start') unless start_container
    true
  end

  def rebuild_container
    return false unless has_api?
    return false unless prep_task(:rebuild)
    ret_val = @container_api.rebuild_image(self)
    expire_engine_info
    if ret_val == true
      register_with_dns # MUst register each time as IP Changes
      #add_nginx_service if @deployment_type == 'web'
      @container_api.register_non_persistant_services(self)
    end
    return true if ret_val
    task_failed('rebuild')
  end
  
  private
  def prep_task(action_sym)

    return log_error_mesg("Action in Progress", task_at_hand) unless task_at_hand.nil? 
    p :current_tah_prep_task
    p task_at_hand
   return false unless in_progress(action_sym)
   p :inproes_run
    clear_error
     return save_state
  rescue StandardError  => e
    log_exception(e)
  end
end