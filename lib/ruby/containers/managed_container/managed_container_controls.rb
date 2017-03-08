module ManagedContainerControls
  def reinstall_engine(builder)
    return false unless has_api?
    return false unless prep_task(:build)
    builder.reinstall_engine(self)

  end

  def update_memory(new_memory)
     super   
     @memory = new_memory
    save_state 
     update_environment('Memory',new_memory,true)
   end
   
  def destroy_container(reinstall=false)

    return false unless has_api?

    if reinstall == true
      return false unless prep_task(:reinstall)
    else
      return false unless prep_task(:destroy)
    end
    return clear_cid if super()
    task_failed('destroy')
  end
  
  def delete_engine
    @container_api.delete_engine(self)
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
    SystemDebug.debug(SystemDebug.containers, :teask_preping)
    @container_mutex.synchronize {
    return false unless prep_task(:create)
    SystemDebug.debug(SystemDebug.containers,  :teask_preped)
    expire_engine_info
    @container_id = -1

    save_state
    return task_failed('create') unless super
    save_state #save new containerid)
    SystemDebug.debug(SystemDebug.containers,  :create_super_ran)
    SystemDebug.debug(SystemDebug.containers,@setState, @docker_info_cache.class.name,  @docker_info_cache)
    expire_engine_info
    state = read_state
   
    
    SystemDebug.debug(SystemDebug.containers,@setState, @docker_info_cache.class.name,  @docker_info_cache)
   # return log_error_mesg('No longer running ' + state + ':' + @setState, @docker_info_cache ,self) unless state == 'running' 
#    register_with_dns # MUst register each time as IP Changes
#    add_nginx_service if @deployment_type == 'web'
#    @container_api.register_non_persistent_services(self)
#    add_nginx_service if @deployment_type == 'web'
    true
    }
  rescue StandardError => e
    log_exception(e)
  end

  def recreate_container

    return task_failed('destroy/recreate') unless destroy_container
    wait_for_task('destroy')
    return task_failed('create/recreate') unless create_container
    true
  end
  


  
  
  def unpause_container

    return false unless has_api?
    @container_mutex.synchronize {
    return r unless (r = prep_task(:unpause))
    return task_failed('unpause') unless super
    #register_with_dns # MUst register each time as IP Changes
   # @container_api.register_non_persistent_services(self)
    true
    }
  end

  def pause_container

    return false unless has_api?
    @container_mutex.synchronize {
    return r unless (r = prep_task(:pause))
    return task_failed('pause') unless super
   # @container_api.deregister_non_persistent_services(self)
    true
    }
  end

  def stop_container
    # allow stopping of nocontainer is dealt with higher up now
    #    if read_state == 'nocontainer'
    #       @setState = 'nocontainer'
    #       return true
    #     end
    SystemDebug.debug(SystemDebug.containers,  :stop_read_sta, read_state)
    return false unless has_api?
    @container_mutex.synchronize {
    return r unless (r = prep_task(:stop))
   # @container_api.deregister_non_persistent_services(self)
    return task_failed('stop') unless super
    true
    }
  end
  def halt_container
    @container_mutex.synchronize {
    return r unless (r = prep_task(:stop))
   # @container_api.deregister_non_persistent_services(self)
     super
    true
    }
  end

  def start_container

    return false unless has_api?
    @container_mutex.synchronize {
    return r unless (r = prep_task(:start))
    return task_failed('start') unless super
    @restart_required = false
  #  register_with_dns # MUst register each time as IP Changes
  #  @container_api.register_non_persistent_services(self)
    true
    }
  end

  def restart_container
    
    return task_failed('restart/stop') unless stop_container
    wait_for_task('stop')
    return task_failed('restart/start') unless start_container
    true
  end

  def rebuild_container
    r = ''
    return false unless has_api?
    @container_mutex.synchronize {
    return r unless (r = prep_task(:reinstall))
    ret_val = @container_api.rebuild_image(self)
    expire_engine_info
#    if ret_val == true
#      register_with_dns # MUst register each time as IP Changes
#      #add_nginx_service if @deployment_type == 'web'
#      @container_api.register_non_persistent_services(self)
#    end
    return true if ret_val
    task_failed('rebuild')
    }
  end

  def correct_current_state
    case @setState
    when 'stopped'
      return stop_container if is_running?      
    when 'running'
      return start_container unless is_active?
      return unpause_container if is_paused?
    when 'nocontainer'
      return create_container
    when 'paused'
      return pause_container unless is_active?
    else
      return 'fail'
    end
    
  end
  
  private

  def prep_task(action_sym)
r = ''
    unless task_at_hand.nil?
      SystemDebug.debug(SystemDebug.containers,  'saved task at hand', task_at_hand, 'next',action_sym )
      # return log_error_mesg("Action in Progress", task_at_hand)
    end
    SystemDebug.debug(SystemDebug.containers,  :current_tah_prep_task, task_at_hand)
    return r unless (r = in_progress(action_sym))
    SystemDebug.debug(SystemDebug.containers,  :inprogress_run)
    clear_error
    return save_state
  rescue StandardError  => e
    log_exception(e)
  end
end