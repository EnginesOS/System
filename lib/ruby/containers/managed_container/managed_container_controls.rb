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
    update_environment('Memory', new_memory, true)
  end

  def destroy_container(reinstall = false)
    return false unless has_api?
    if reinstall == true
      return false unless prep_task(:reinstall)
    else
      return false unless prep_task(:destroy)
    end
    return task_failed('destroy') unless super() # need () to avoid passing as super(reinstall)
    clear_cid
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
      raise EnginesException.new(warning_hash('Cannot create container as container exists ', state))
    end
    return true if ret_val
    task_failed('setup')
  end

  def create_container
    return false unless has_api?
    SystemDebug.debug(SystemDebug.containers, :teask_preping)
    @container_mutex.synchronize {
      @container_api.set_locale(self)
      return false unless prep_task(:create)
      SystemDebug.debug(SystemDebug.containers, :teask_preped)
      expire_engine_info
      @container_id = -1
      save_state
      return task_failed('create') unless super
      save_state #save new containerid)
      SystemDebug.debug(SystemDebug.containers,  :create_super_ran)
      SystemDebug.debug(SystemDebug.containers,@setState, @docker_info_cache.class.name,  @docker_info_cache)
      expire_engine_info
      SystemDebug.debug(SystemDebug.containers,@setState, @docker_info_cache.class.name,  @docker_info_cache)
      true
    }
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
      return false unless (r = prep_task(:unpause))
      return task_failed('unpause') unless super
      true
    }
  end

  def pause_container
    return false unless has_api?
    @container_mutex.synchronize {
      return r unless (r = prep_task(:pause))
      return task_failed('pause') unless super
      true
    }
  end

  def stop_container
    SystemDebug.debug(SystemDebug.containers,  :stop_read_sta, read_state)
    return false unless has_api?
    @container_mutex.synchronize {
      return r unless (r = prep_task(:stop))
      return task_failed('stop') unless super
      true
    }
  end

  def halt_container
    @container_mutex.synchronize {
      return r unless (r = prep_task(:stop))
      super
    }
  end

  def start_container
    return false unless has_api?
    @container_mutex.synchronize {
      return r unless (r = prep_task(:start))
      return task_failed('start') unless super
      @restart_required = false
    }
  end

  def restart_container
    return task_failed('restart/stop') unless stop_container
    wait_for_task('stop')
    task_failed('restart/start') unless start_container
  end

  def rebuild_container
    return false unless has_api?
    @container_mutex.synchronize {
      return r unless (r = prep_task(:reinstall))
      ret_val = @container_api.rebuild_image(self)
      expire_engine_info
      return true if ret_val
      task_failed('rebuild')
    }
  end

  def correct_current_state
    case @setState
    when 'stopped'
       stop_container if is_running?
    when 'running'
       start_container unless is_active?
       unpause_container if is_paused?
    when 'nocontainer'
      create_container
    when 'paused'
       pause_container unless is_active?
    else
      return 'fail'
    end
  end

  private

  def prep_task(action_sym)
    unless task_at_hand.nil?
      SystemDebug.debug(SystemDebug.containers,  'saved task at hand', task_at_hand, 'next',action_sym )
    end
    SystemDebug.debug(SystemDebug.containers,  :current_tah_prep_task, task_at_hand)
    return r unless (r = in_progress(action_sym))
    SystemDebug.debug(SystemDebug.containers,  :inprogress_run)
    clear_error
    save_state
  end
end