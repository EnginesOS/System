module ManagedContainerControls
  def reinstall_engine
    container_mutex.synchronize {
    build_controller.reinstall_engine( {
      engine_name: container_name,
      domain_name: domain_name,
      host_name: hostname,
      software_environment_variables: environments,
      http_protocol: protocol,
      memory: memory,
      permission_as: container_name,
      repository_url: container_name,
      variables: environments,
      reinstall: true
    }) if prep_task(:build) }
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Reinstall:' + container_name)
  end

  def wait_for_startup(timeout = 60)
    container_dock.wait_for_startup(self, timeout)
  end

  def update_memory(new_memory)
    container_mutex.synchronize {
      super
      @memory = new_memory
      update_environment('Memory', new_memory, true)
      save_state
    }
  end

  def destroy_container(reinstall = false)
    thr = Thread.new do
      container_mutex.synchronize {
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
      }
    end
    thr.name = "Destroy:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Destroy:' + container_name)
    thr.exit unless thr.nil?
  end

  def delete_engine
    thr = Thread.new do
      container_mutex.synchronize {
        container_dock.delete_engine(self)
      }
    end
    thr.name = "Delete:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Delete Engine:' + container_name)
    thr.exit unless thr.nil?
  end

  def create_container
    #   SystemDebug.debug(SystemDebug.containers, :teask_preping)
    thr = Thread.new do
      container_mutex.synchronize {
        if prep_task(:create)
          @domain_name = container_dock.default_domain if @domain_name.nil?
          container_dock.initialize_container_env(self)
          #  SystemDebug.debug(SystemDebug.containers, :teask_preped)
          expire_engine_info
          @id = nil
          save_state
          unless super
            task_failed('create')
          else
            save_state #save new containerid)
            #    SystemDebug.debug(SystemDebug.containers, :create_super_ran)
            #   SystemDebug.debug(SystemDebug.containers, @setState, @docker_info_cache.class.name)
            expire_engine_info
            #   SystemDebug.debug(SystemDebug.containers, @setState, @docker_info_cache.class.name)
            true
          end
        end
      }
    end
    thr.name = "Create:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Create:' + container_name)
    thr.exit unless thr.nil?
  end

  def recreate_container
    thr = Thread.new do
      destroy_container
      wait_for('destroy', 30)
      create_container
    end
    thr.name = "Recreate:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'ReCreate:' + container_name)
    thr.exit unless thr.nil?
  end

  def unpause_container
    thr = Thread.new do
      container_mutex.synchronize {
        if prep_task(:unpause)
          if super
            true
          else
            task_failed('unpause')
          end
        end
      }
    end
    thr.name = "Unpause:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Unpause :' + container_name)
    thr.exit unless thr.nil?

  end

  def pause_container
    thr = Thread.new do
      container_mutex.synchronize {
        if prep_task(:pause)
          if super
            true
          else
            task_failed('pause')
          end
        end
      }
    end
    thr.name = "Pause:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Pause:' + container_name)
    thr.exit unless thr.nil?
  end

  def stop_container
    thr = Thread.new do
      container_mutex.synchronize {
        if prep_task(:stop)
          if super
            true
          else
            task_failed('stop')
          end
        end
      }
    end
    thr.name = "Stop:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Stop:' + container_name)
    thr.exit unless thr.nil?
  end

  def halt_container
    thr = Thread.new do
      container_mutex.synchronize {
        super if prep_task(:halt)
      }
    end
    thr.name = "Halt:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Halt:' + container_name)
    thr.exit unless thr.nil?
  end

  def start_container
    thr = Thread.new do
      container_mutex.synchronize {
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
    thr.name = "Start:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Start:' + container_name)
    thr.exit unless thr.nil?
  end

  def restart_container
    thr = Thread.new do
      sthr = stop_container
      sthr.join
      wait_for('stop')
      start_container
    end
    thr.name = "Restart:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Restart:' + container_name)
    thr.exit unless thr.nil?
  end

  def restore_engine
    container_mutex.synchronize {
    build_controller.restore_engine({
      engine_name: container_name,
      domain_name: domain_name,
      host_name: hostname,
      software_environment_variables: environments,
      http_protocol: protocol,
      memory: memory,
      repository_url: container_name,
      variables: environments,
      reinstall: true,
      restore: true
    }) if prep_task(:build)}
  end

  def rebuild_container
    thr = Thread.new do
      container_mutex.synchronize {
        if prep_task(:reinstall)
          ret_val = container_dock.rebuild_image(self)
          expire_engine_info
          if ret_val
            true
          else
            task_failed('rebuild')
          end
        end
      }
    end
    thr.name = "Rebuild:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Restore:' + container_name)
    thr.exit unless thr.nil?
  end

  def correct_current_state
    case @setState
    when 'stopped'
      stop_container if is_running?
    when 'running'
      if has_container?
        start_container unless is_active?
        unpause_container if is_paused?
      else
        create_container
      end
    when 'nocontainer'
      unpause_container if is_paused?
      stop_container if is_active?
      destroy_container if has_container?
    when 'paused'
      pause_container unless is_active?
    else
      false
    end
  end

  protected

  def build_controller
    @builder ||= BuildController.instance
  end

  protected

  def container_mutex
    @container_mutex ||= Mutex.new
  end

  def prep_task(action_sym)
    tah = task_at_hand
    STDERR.puts("TAH   #{tah} action #{action_sym}")
    r = in_progress(action_sym)
    STDERR.puts('in_progress ' + r.to_s)
#    if in_progress(action_sym) 
#      STDERR.puts('SAVE STATE :inprogress_run  ')
#      save_state
#    end
    #will return false if task in progress
   true
  end
end