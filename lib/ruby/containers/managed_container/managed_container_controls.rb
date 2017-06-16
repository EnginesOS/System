module ManagedContainerControls
  def reinstall_engine(builder)
    builder.reinstall_engine(self) if prep_task(:build)
  end

  def wait_for_startup(timeout = 60)
    STDERR.puts( 'Wait for Startup ' + @container_name)
    @container_api.wait_for_startup(self, timeout)
  end

  def update_memory(new_memory)
    super
    @memory = new_memory
    save_state
    update_environment('Memory', new_memory, true)
  end

  def destroy_container(reinstall = false)
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
    if prep_task(:create)
      ret_val = false
      unless has_container?
        ret_val = @container_api.setup_container(self)
        expire_engine_info
      else
        task_failed('setup')
        raise EnginesException.new(warning_hash('Cannot create container as container exists ', state))
      end
      retval = task_failed('setup') unless ret_val
    else
      retval = false
    end
    retval
  end

  def create_container
    SystemDebug.debug(SystemDebug.containers, :teask_preping)
    @container_mutex.synchronize {
      @container_api.set_locale_env(self)
      if prep_task(:create)
        SystemDebug.debug(SystemDebug.containers, :teask_preped)
        expire_engine_info
        @container_id = -1
        save_state
        return task_failed('create') unless super
        save_state #save new containerid)
        SystemDebug.debug(SystemDebug.containers, :create_super_ran)
        SystemDebug.debug(SystemDebug.containers, @setState, @docker_info_cache.class.name)
        expire_engine_info
        SystemDebug.debug(SystemDebug.containers, @setState, @docker_info_cache.class.name)
        true
      end
    }
  end

  def recreate_container
    return task_failed('destroy/recreate') unless destroy_container
    wait_for('destroy')
    return task_failed('create/recreate') unless create_container
    true
  end

  def unpause_container
    @container_mutex.synchronize {
      if prep_task(:unpause)
        return task_failed('unpause') unless super
        true
      end
    }
  end

  def pause_container
    @container_mutex.synchronize {
      if prep_task(:pause)
        return task_failed('pause') unless super
        true
      end
    }
  end

  def stop_container
    SystemDebug.debug(SystemDebug.containers, :stop_read_sta, read_state)
    @container_mutex.synchronize {
      if prep_task(:stop)
        return task_failed('stop') unless super
        true
      end
    }
  end

  def halt_container
    @container_mutex.synchronize {
      super if prep_task(:halt)
    }
  end

  def start_container
    @container_mutex.synchronize {
      if prep_task(:start)
        return task_failed('start') unless super
        @restart_required = false
        true
      end
    }
  end

  def restart_container
    return task_failed('restart/stop') unless stop_container
    wait_for('stop')
    task_failed('restart/start') unless start_container
    true
  end

  def rebuild_container
 
    @container_mutex.synchronize {
      if prep_task(:reinstall)
        ret_val = @container_api.rebuild_image(self)
        expire_engine_info
        return task_failed('rebuild') unless ret_val
        true
      end
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
    tah = task_at_hand
    unless tah.nil?
      SystemDebug.debug(SystemDebug.containers, 'saved task at hand', tah, 'next', action_sym)
    end
    SystemDebug.debug(SystemDebug.containers, :current_tah_prep_task, tah)
    unless in_progress(action_sym)
      SystemDebug.debug(SystemDebug.containers, :inprogress_run)
      save_state
    end
    true
  end
end