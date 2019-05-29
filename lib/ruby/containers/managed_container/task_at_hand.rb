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
   # SystemDebug.debug(SystemDebug.engine_tasks, 'Task at Hand:' + state.to_s + ' Current set state:' + current_set_state.to_s + '  going for:' +  @setState  + ' with ' + @task_at_hand.to_s + ' in ' + curr_state)
    # rescue StandardError => e
    #   log_exception(e)
  end

  def in_progress(action)
    curr_state = read_state
    final_state = tasks_final_state(action)
 #   SystemDebug.debug(SystemDebug.engine_tasks, :final_state, final_state)
    if final_state == curr_state && action != 'restart'
      @setState = curr_state
      @container_id ==  -1 if curr_state == 'nocontainer'
    #  SystemDebug.debug(SystemDebug.engine_tasks, :curr_state, curr_state)
      return save_state
    end
    if @steps_to_go.nil? || @steps_to_go <= 0
      @steps_to_go = 1
      @steps = []
      @steps[0] = action
    end
    step = @steps[0]

  #  SystemDebug.debug(SystemDebug.engine_tasks, :read_state, curr_state)
    # FIX ME Finx the source 0 :->:
    curr_state.sub!(/\:->\:/,'')
    @last_task = action
    r = log_error_mesg(@container_name + ' not in matching state want _' + tasks_final_state(action).to_s + '_but in ' + curr_state.class.name + ' ', curr_state )
    case action
    when :create
      @steps = [:create, :start]
      @steps_to_go = 2
      r = desired_state(step, final_state, curr_state) if curr_state== 'nocontainer'
    when :stop
  #    STDERR.puts(' stop  steps' + @steps.to_s + ' count ' + @steps_to_go.to_s)
      r = desired_state(step, final_state, curr_state) if curr_state== 'running'
    when :start
  #    STDERR.puts(' start  steps' + @steps.to_s + ' count ' + @steps_to_go.to_s)
      r = desired_state(step, final_state, curr_state) if curr_state== 'stopped'
    when :pause
   #   STDERR.puts(' pause  steps' + @steps.to_s + ' count ' + @steps_to_go.to_s)
      r = desired_state(step, final_state, curr_state) if curr_state== 'running'
    when :halt
      r = true
    when :restart
      if curr_state == 'running'
        @steps = [:stop, :start]
        @steps_to_go = 2
        r = desired_state(step, final_state, curr_state)
      else
        r = desired_state(step, final_state, curr_state)
      end
    when :unpause
      r = desired_state(step, final_state, curr_state) if curr_state== 'paused'
    when :recreate
      if curr_state== 'stopped'
        @steps = [:destroy, :create]
        @steps_to_go = 2
        r = desired_state(step, final_state, curr_state)
      else
        r = desired_state(step, final_state, curr_state) if curr_state== 'nocontainer'
      end
    when :build
      if curr_state == 'noncontainer'
        @steps = [:build]
        @steps_to_go = 1
        r = desired_state(step, final_state, curr_state)
      else
        r = desired_state(step, final_state, curr_state) if curr_state == 'nocontainer'
      end
    when :reinstall
      if curr_state == 'stopped'
        @steps = [:destroy, :build]
        @steps_to_go = 2
        r = desired_state(step, final_state, curr_state)
      else
        r = desired_state(step, final_state, curr_state) if curr_state== 'nocontainer'
      end
    when :build
      r = desired_state(step, final_state, curr_state) if curr_state== 'nocontainer'
    when :delete
      r = desired_state(step, final_state, curr_state) if curr_state== 'stopped'
      #  desired_state(@steps, 'noimage')
    when :destroy
      r = desired_state(step, final_state, curr_state) if curr_state== 'stopped' || curr_state== 'nocontainer'
    end
    r
  end

  def process_container_event(event_hash)
    expire_engine_info
  #  SystemDebug.debug(SystemDebug.container_events, :PROCESS_CONTAINER_vents, @container_name,  event_hash)
    case event_hash[:status]
    when 'create'
      status
      on_create(event_hash)
    when 'start'
      status
      on_start('start')
    when 'unpause'
      status
      on_start('unpause')
    when 'die'
      status
      begin
        # STDERR.puts('IT DIED WITH ' + event_hash[:Actor][:Attributes][:exitCode].to_s)
        ec = event_hash[:Actor][:Attributes][:exitCode]
      rescue
        ec = 0
      end
      on_stop('die', ec)
    when 'kill'
      status
      #  STDERR.puts('IT KILL')
      on_stop('kill')
    when 'stop'
      status
      on_stop('stop')
      #  STDERR.puts('IT STOP')
    when 'pause'
      status
      on_stop('pause')
    when 'oom'
      status
      out_of_mem('oom')
    when 'destroy'
      status
    end
    true
  rescue StandardError => e
    log_exception(e)
  end

  def task_complete(action)

    @steps_to_go = 0 if @steps_to_go.nil?
  #  SystemDebug.debug(SystemDebug.engine_tasks, :task_complete, ' ', action.to_s + ' as action for task ' +  task_at_hand.to_s + " " + @steps_to_go.to_s + '-1 stesp remaining step completed ',@steps)

    clear_task_at_hand
   # SystemDebug.debug(SystemDebug.builder, :last_task,  @last_task, :steps_to, @steps_to_go)
    return save_state unless @last_task == :delete_image && @steps_to_go <= 0
    # FixMe Kludge unless docker event listener
 #   SystemDebug.debug(SystemDebug.builder, :delete_engine,  @last_task, :steps_to, @steps_to_go)
    delete_engine
    true
    # rescue StandardError => e
    #   log_exception(e)
  end

  def task_at_hand
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
 #   SystemDebug.debug(SystemDebug.containers, :task_at_handfile, + ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
    if File.exist?(fn)
      thf = File.new(fn, 'r')
      begin
        @task_at_hand = nil
        @task_at_hand = thf.read
      ensure
        thf.close
        nil
      end
      unless @task_at_hand.nil?
     #   SystemDebug.debug(SystemDebug.containers, :task_at_hand_read_as, @task_at_hand)
        if task_has_expired?(@task_at_hand)
          expire_task_at_hand
     #     SystemDebug.debug(SystemDebug.containers, :task_at_hand_expired)
        elsif tasks_final_state(@task_at_hand) == read_state(raw = true)
          clear_task_at_hand
    #      SystemDebug.debug(SystemDebug.containers, :task_at_clear)
        else
      #    SystemDebug.debug(SystemDebug.containers, :task_at_is, @task_at_hand)
          @task_at_hand
        end
      else
        nil
      end
    else
      nil
    end
  rescue StandardError => e
    log_exception(e) if File.exist?(fn)

    nil
    # @task_at_hand
  end

  def expire_task_at_hand
#    SystemDebug.debug(SystemDebug.engine_tasks, 'expire Task ' + @task_at_hand.to_s )
    clear_task_at_hand
  end

  def clear_task_at_hand
    @steps_to_go -= 1
    if  @steps_to_go > 0
  #    SystemDebug.debug(SystemDebug.engine_tasks, 'Multistep Task ' + @task_at_hand.to_s )
      if @steps.is_a?(Array)
        @steps.pop(0)
        @task_at_hand = @steps[0]
      end
    #  SystemDebug.debug(SystemDebug.engine_tasks, 'next Multistep Task ' + @task_at_hand.to_s)
      f = File.new(ContainerStateFiles.container_state_dir(self) + '/task_at_hand','w+')
      begin
        f.write(@task_at_hand.to_s)
      ensure
        f.close
      end
    else
  #   SystemDebug.debug(SystemDebug.engine_tasks, 'cleared Task ' + @task_at_hand.to_s)
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
 #   SystemDebug.debug(SystemDebug.engine_tasks, :TASK_FAILES______Doing, @task_at_hand)
    @last_error = @container_api.last_error unless @container_api.nil?
  #  SystemDebug.debug(SystemDebug.engine_tasks, :WITH, @last_error.to_s, msg.to_s)
    task_complete(:failed)
    false
  end

  private

  def tasks_final_state(task)
    case task.to_sym
    when :create,:start,:recreate,:unpause,:restart,:rebuild,:build,:reinstall
      s = 'running'
    when :stop
      s = 'stopped'
    when :pause
      s =  'paused'
    when :delete,:destroy
      s = 'nocontainer'
    else
      STDERR.puts('UNKNOWN TASK ' + task.to_s)
      s = ''
    end
    s
  end

  def task_has_expired?(task)
    fmtime = File.mtime(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
    mtime = fmtime  + task_set_timeout(task)
  #  SystemDebug.debug(SystemDebug.container, mtime, fmtime, task, task_set_timeout(task))
    if mtime < Time.now
      File.delete(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
   #   SystemDebug.debug(SystemDebug.engine_tasks, :expired_task, task, ' after ', task_set_timeout(task))
      true
    else
      false
    end
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
    if Dir.exist?(ContainerStateFiles.container_state_dir(self)) # happens on reinstall
      f = File.new(ContainerStateFiles.container_state_dir(self) + '/task_at_hand', 'w+')
      begin
        f.write(state)
      ensure
        f.close
      end
    end
  rescue StandardError => e
    log_exception(e)
  end
end