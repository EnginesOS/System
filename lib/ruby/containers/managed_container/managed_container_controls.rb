module ManagedContainerControls
  def reinstall_engine(builder)
    builder.reinstall_engine(self) if prep_task(:build)
  end

  def wait_for_startup(timeout = 60)
    @container_api.wait_for_startup(self, timeout)
  end

  def update_memory(new_memory)
    super
    @memory = new_memory
    save_state
    update_environment('Memory', new_memory, true)
  end

  def destroy_container(reinstall = false)
    thr = Thread.new do
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
    thr.name('Destroy:' + container_name)
    'ok'
  end

  def delete_engine
    thr = Thread.new do
      @container_api.delete_engine(self)
    end
    thr.name('Delete:' + container_name)
    'ok'
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
    thr = Thread.new do
      @container_mutex.synchronize {
        if prep_task(:create)
          @domain_name = @container_api.default_domain if @domain_name.nil?
          @container_api.initialize_container_env(self)
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
    thr.name('Create:' + container_name)
    'ok'
  end

  def recreate_container
    thr = Thread.new do
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
    thr.name('Recreate:' + container_name)
    'ok'
  end

  def unpause_container
    thr = Thread.new do
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
    thr.name('Unpause:' + container_name)
    'ok'
  end

  def pause_container
    thr = Thread.new do
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
    thr.name('Pause:' + container_name)
    'ok'
  end

  def stop_container
    thr = Thread.new do
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
    thr.name('Stop:' + container_name)
    'ok'
  end

  def halt_container
    thr = Thread.new do
      @container_mutex.synchronize {
        super if prep_task(:halt)
      }
    end
    thr.name('Halt:' + container_name)
    'ok'
  end

  def start_container
    thr = Thread.new do
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
    thr.name('Start:' + container_name)
    'ok'
  end

  def restart_container
    thr = Thread.new do
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
    thr.name('Restart:' + container_name)
    'ok'
  end

  def restore_engine(builder)
    builder.restore_engine(self) if prep_task(:build)
  end

  def rebuild_container
    thr = Thread.new do

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
    thr.name('Rebuild:' + container_name)
    'ok'
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