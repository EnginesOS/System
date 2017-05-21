module TaskAtHand

  @task_queue = []
  def init_task_at_hand
    @steps = []
  end

  def desired_state(step, state, curr_state)
    current_set_state = @setState
    @setState = state.to_s
    set_task_at_hand(step)
    save_state
    SystemDebug.debug(SystemDebug.engine_tasks,  'Task at Hand:' + state.to_s + '  Current set state:' + current_set_state.to_s + '  going for:' +  @setState  + ' with ' + @task_at_hand.to_s + ' in ' + curr_state)
    # rescue StandardError => e
    #   log_exception(e)
  end

  def in_progress(action)
    curr_state = read_state
    final_state = tasks_final_state(action)
    if final_state == curr_state && action != 'restart'
      @setState = curr_state
      @container_id ==  -1 if curr_state == 'nocontainer'
      return save_state
    end
    if @steps_to_go.nil? || @steps_to_go <= 0
      @steps_to_go = 1
      @steps = []
      @steps[0] = action
    end
    step = @steps[0]

    SystemDebug.debug(SystemDebug.engine_tasks, :read_state, curr_state)
    # FIX ME Finx the source 0 :->:
    curr_state.sub!(/\:->\:/,'')
    @last_task = action

    case action
    when :create
      @steps = [:create,:start]
      @steps_to_go = 2
      return desired_state(step, final_state, curr_state) if curr_state== 'nocontainer'
    when :stop
      return desired_state(step, final_state, curr_state) if curr_state== 'running'
    when :start
      return desired_state(step, final_state, curr_state) if curr_state== 'stopped'
    when :pause
      return desired_state(step, final_state, curr_state) if curr_state== 'running'

    when :restart
      if curr_state == 'running'
        @steps = [:stop,:start]
        @steps_to_go = 2
        return desired_state(step, final_state, curr_state)
      end
      return desired_state(step, final_state, curr_state)
    when :unpause
      return desired_state(step, final_state, curr_state) if curr_state== 'paused'
    when :recreate
      if curr_state== 'stopped'
        @steps = [:destroy,:create]
        @steps_to_go = 2
        return desired_state(step, final_state, curr_state)
      end
      return desired_state(step, final_state, curr_state) if  curr_state== 'nocontainer'

    when :build
      if curr_state == 'noncontainer'
        @steps = [:build]
        @steps_to_go = 1
        return desired_state(step, final_state, curr_state)
      end
      return desired_state(step, final_state, curr_state) if  curr_state== 'nocontainer'

    when :reinstall
      if curr_state == 'stopped'
        @steps =  [:destroy,:build]
        @steps_to_go = 2
        return desired_state(step, final_state, curr_state)
      end

      return desired_state(step, final_state, curr_state) if  curr_state== 'nocontainer'
    when :build
      return desired_state(step, final_state, curr_state) if curr_state== 'nocontainer'
    when :delete
      return desired_state(step, final_state, curr_state) if curr_state== 'stopped'
      #  desired_state(@steps, 'noimage')
    when :destroy
      return desired_state(step, final_state, curr_state) if curr_state== 'stopped' || curr_state== 'nocontainer'
    end

    return log_error_mesg(@container_name + ' not in matching state want _' + tasks_final_state(action).to_s + '_but in ' + curr_state.class.name + ' ',curr_state )

    # Perhaps ?return clear_task_at_hand
 # rescue StandardError => e
 #   log_exception(e)
  end

  def process_container_event(event, event_hash)
    expire_engine_info
    SystemDebug.debug(SystemDebug.container_events, :PROCESS_CONTAINER_vents, @container_name, event, event_hash)
    case event
    when 'create'
      on_create(event_hash)
    when 'start'
      on_start('start')
    when 'unpause'
      on_start('unpause')
    when 'die'
      STDERR.puts('IT DIED')
      on_stop('die')
    when 'kill'
      STDERR.puts('IT KILL')
      on_stop('kill')
    when 'stop'
      on_stop('stop')
      STDERR.puts('IT STOP')
    when 'pause'
      on_stop('pause')
    when 'oom'
      out_of_mem('oom')
    end
    true
#  rescue StandardError => e
#    log_exception(e)
  end

  def task_complete(action)

    @steps_to_go = 0 if @steps_to_go.nil?
    SystemDebug.debug(SystemDebug.engine_tasks, :task_complete, ' ', action.to_s + ' as action for task ' +  task_at_hand.to_s + " " + @steps_to_go.to_s + '-1 stesp remaining step completed ',@steps)

    clear_task_at_hand
    SystemDebug.debug(SystemDebug.builder, :last_task,   @last_task, :steps_to, @steps_to_go)
    return save_state unless @last_task == :delete_image && @steps_to_go <= 0
    # FixMe Kludge unless docker event listener
    delete_engine
    true
 # rescue StandardError => e
 #   log_exception(e)
  end

  def task_at_hand
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    return nil unless File.exist?(fn)
    thf = File.new(fn, 'r')
    begin
      @task_at_hand = nil
      @task_at_hand = thf.read
    ensure
      thf.close
    end

    if task_has_expired?(@task_at_hand)
      expire_task_at_hand
      return nil
    end
    r = read_state(raw = true)
    if tasks_final_state(@task_at_hand) == r
      clear_task_at_hand
      return nil
    end
    @task_at_hand
  rescue StandardError => e
    return nil unless File.exist?(fn)
    log_exception(e)
    nil
    # @task_at_hand
  end

  def expire_task_at_hand
    SystemDebug.debug(SystemDebug.engine_tasks, 'expire Task ' + @task_at_hand.to_s )
    clear_task_at_hand
  end

  def clear_task_at_hand
    @steps_to_go -= 1
    if  @steps_to_go > 0
      SystemDebug.debug(SystemDebug.engine_tasks, 'Multistep Task ' + @task_at_hand.to_s )
      if @steps.is_a?(Array)
        @steps.pop(0)
        @task_at_hand = @steps[0]
      end
      SystemDebug.debug(SystemDebug.engine_tasks, 'next Multistep Task ' + @task_at_hand.to_s)
      f = File.new(ContainerStateFiles.container_state_dir(self) + '/task_at_hand','w+')
      f.write(@task_at_hand.to_s)
      f.close
    else
      SystemDebug.debug(SystemDebug.engine_tasks, 'cleared Task ' + @task_at_hand.to_s)
      @task_at_hand = nil
      fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
      File.delete(fn) if File.exist?(fn)
    end

  rescue StandardError => e
    # log_exception(e) Dont log exception
    # well perhaps a perms or disk error but definitly not no such file
    true  #possbile exception such file (another process alsop got the eot mesg and removed)
  end

  def task_failed(msg)
    clear_task_at_hand
    SystemDebug.debug(SystemDebug.engine_tasks,:TASK_FAILES______Doing, @task_at_hand)
    @last_error = @container_api.last_error unless @container_api.nil?
    SystemDebug.debug(SystemDebug.engine_tasks, :WITH, @last_error.to_s, msg.to_s)
    task_complete(:failed)
    false
  end


  private

  def tasks_final_state(task)
    case task
    when :create
      return 'running'
    when :stop
      return 'stopped'
    when :start
      return 'running'
    when :pause
      return 'paused'
    when :restart
      return 'stopped'
    when :unpause
      return 'running'
    when :reinstall
      return 'running'
    when :recreate
      return 'running'
    when :rebuild
      return 'running'
    when :build
      return 'running'
    when :delete
      return 'nocontainer'
    when :destroy
      return 'nocontainer'
    end
 # rescue StandardError => e
#    log_exception(e)
  end

  def task_has_expired?(task)
    fmtime = File.mtime(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
    mtime = fmtime  + task_set_timeout(task)
    #SystemDebug.debug(SystemDebug.engine_tasks,mtime,fmtime,task,task_set_timeout(task))
    if mtime < Time.now
      File.delete(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
      SystemDebug.debug(SystemDebug.engine_tasks, :expired_task, task, ' after ' , task_set_timeout(task))
      return true
    end
    false
    # no file problem with mtime etc means task has finished in progress and task file has dissapppeared
  rescue StandardError => e
    # SystemDebug.debug(SystemDebug.engine_tasks, e, e.backtrace)
    true
  end

  require_relative 'task_timeouts.rb'

  def task_set_timeout(task)
    TaskTimeouts.task_set_timeout(task)
  end

  def set_task_at_hand(state)
    @task_at_hand = state
    return unless Dir.exist?(ContainerStateFiles.container_state_dir(self)) # happens on reinstall
    f = File.new(ContainerStateFiles.container_state_dir(self) + '/task_at_hand','w+')
    f.write(state)
    f.close
  rescue StandardError => e
    log_exception(e)
  end
end