module ManagedContainerControls
  def reinstall_engine
    container_mutex.synchronize {
      prep_task(:build)
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
      })  
      task_failed(:reinstall, e) }
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Reinstall:' + container_name)
    raise e
  end

  def wait_for_startup(timeout = 60)
    container_dock.wait_for_startup(self, timeout)
  end

  def update_memory(new_memory)
    container_mutex.synchronize {
      super
      self.memory = new_memory
      update_environment('Memory', new_memory, true)
      save_state
    }
  end

  def destroy_container(reinstall = false)
    thr = Thread.new do
      container_mutex.synchronize {
        STDERR.puts "Des" * 20
        if reinstall == true
          prep_task(:reinstall)
        else
          prep_task(:destroy)
        end

        super()  # need () to avoid passing as super(reinstall)
        STDERR.puts "troy" * 20
        clear_cid
      }
    end
    thr.name = "Destroy:#{container_name}"
    thr
  rescue StandardError => e
    SystemUtils.log_exception(e , 'Destroy:' + container_name)
    thr.exit unless thr.nil?
    task_failed(:destroy, e)
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
    task_failed(:delete, e)
  end

  def create_container
    #   SystemDebug.debug(SystemDebug.containers, :teask_preping)
    thr = Thread.new do
      container_mutex.synchronize {
        prep_task(:create)
        self.domain_name = container_dock.default_domain if domain_name.nil?
        container_dock.initialize_container_env(self)
        #  SystemDebug.debug(SystemDebug.containers, :teask_preped)
        expire_engine_info
        self.id = nil
        save_state
        super
        save_state #save new containerid)
        #    SystemDebug.debug(SystemDebug.containers, :create_super_ran)
        #   SystemDebug.debug(SystemDebug.containers, set_state, @docker_info_cache.class.name)
        expire_engine_info
        #   SystemDebug.debug(SystemDebug.containers, set_state, @docker_info_cache.class.name)
      }
    end
    thr.name = "Create:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Create:' + container_name)
    thr.exit unless thr.nil?
    task_failed(:create, e)
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
    task_failed(:recreate, e)
  end

  def unpause_container
    thr = Thread.new do
      container_mutex.synchronize {
        prep_task(:unpause)
        super
      }
    end
    thr.name = "Unpause:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Unpause :' + container_name)
    thr.exit unless thr.nil?
    task_failed(:unpause, e)
  end

  def pause_container
    thr = Thread.new do
      container_mutex.synchronize {
        prep_task(:pause)
        super
      }
    end
    thr.name = "Pause:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Pause:' + container_name)
    thr.exit unless thr.nil?
    task_failed(:pause, e)
  end

  def stop_container
    STDERR.puts "STOP" * 20
    thr = Thread.new do
      container_mutex.synchronize {
        prep_task(:stop)
        super
      }
    end
    thr.name = "Stop:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Stop:' + container_name)
    thr.exit unless thr.nil?
    task_failed(:stop, e)
  end

  def halt_container
    thr = Thread.new do
      container_mutex.synchronize {
        prep_task(:halt)
        super
      }
    end
    thr.name = "Halt:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Halt:' + container_name)
    thr.exit unless thr.nil?
    task_failed(:halt, e)
  end

  def start_container
    thr = Thread.new do
      container_mutex.synchronize {
        prep_task(:start)
        super
        restart_required = false
      }
    end
    thr.name = "Start:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Start:' + container_name)
    thr.exit unless thr.nil?
    raise e
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
    raise e
  end

  def restore_engine
    container_mutex.synchronize {
      prep_task(:build)}
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
    })
  end

  def rebuild_container
    thr = Thread.new do
      container_mutex.synchronize {
        prep_task(:reinstall)
        ret_val = container_dock.rebuild_image(self)
        expire_engine_info
      }
    end
    thr.name = "Rebuild:#{container_name}"
    thr
  rescue StandardError =>e
    SystemUtils.log_exception(e , 'Restore:' + container_name)
    thr.exit unless thr.nil?
    raise e
  end

  def correct_current_state
    case set_state
    when :stopped
      stop_container if is_running?
    when :running
      if has_container?
        start_container unless is_active?
        unpause_container if is_paused?
      else
        create_container
      end
    when :nocontainer
      unpause_container if is_paused?
      stop_container if is_active?
      destroy_container if has_container?
    when :paused
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
    STDERR.puts('Taks in progress') unless task_at_hand.nil? #FIX ME if task at hand return !nil? already in progress to
    self.set_state = tasks_final_state(action_sym)
    if read_state == set_state
      expire_engine_info
      status
      save_state
      'Already'
    else
      create_steps
      save_state
    end
  end
end
