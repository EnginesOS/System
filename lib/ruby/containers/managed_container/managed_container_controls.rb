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
      task = prep_task(:reinstall)
    else
      task = prep_task(:destroy)
    end
    if task
      if super()  # need () to avoid passing as super(reinstall)
        clear_cid
        true
      else
        task_failed('destroy') # need () to avoid passing as super(reinstall)
      end
    else
      false
    end
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
        unless super
          task_failed('create')
        else
          save_state #save new containerid)
          SystemDebug.debug(SystemDebug.containers, :create_super_ran)
          SystemDebug.debug(SystemDebug.containers, @setState, @docker_info_cache.class.name)
          expire_engine_info
          SystemDebug.debug(SystemDebug.containers, @setState, @docker_info_cache.class.name)
          true
        end
      end
    }
  end

  def recreate_container
    if destroy_container
      wait_for('destroy', 30)
      if create_container
        true
      else
        task_failed('create/recreate')
      end
    else
      task_failed('destroy/recreate')
    end
  end

  def unpause_container
    @container_mutex.synchronize {
      if prep_task(:unpause)
        if super
          true
        else
          task_failed('unpause')
        end
      end
    }
  end

  def pause_container
    @container_mutex.synchronize {
      if prep_task(:pause)
        if super
          true
        else
          task_failed('pause')
        end
      end
    }
  end

  def stop_container
    SystemDebug.debug(SystemDebug.containers, :stop_read_sta, read_state)
    @container_mutex.synchronize {
      if prep_task(:stop)
        if super
          true
        else
          task_failed('stop')
        end
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
        if super
          @restart_required = false
          true
        else
          task_failed('start')
        end
      end
    }
  end

  def restart_container
    if stop_container
      wait_for('stop')
      if start_container
        true
      else
        task_failed('restart/start')
      end
    else
      task_failed('restart/stop')
    end
  end
  
  def restore_container(builder)
      builder.restore_engine(self)    
  end

  def rebuild_container

    @container_mutex.synchronize {
      if prep_task(:reinstall)
        ret_val = @container_api.rebuild_image(self)
        expire_engine_info
        if ret_val
          true
        else
          task_failed('rebuild')
        end
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
      'fail'
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