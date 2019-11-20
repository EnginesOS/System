module TaskAtHand

  @task_queue = []


  def create_steps
    STDERR.puts("Set state #{self.set_state} #{set_state}")

    curr_state = read_state
    curr_state.sub!(/\:->\:/,'')
     steps = [] if steps.nil?



    case set_state
    when :create
      steps = [:create, :start]
    when :stop, :start, :pause, :halt, :unpause, :delete, :destroy,
      steps[0] = set_state
    when :restart
      if curr_state == 'running'
        steps = [:stop, :start]
      end
    when :recreate
      if curr_state == 'stopped'
        steps = [:destroy, :create]
      else
      end
    when :build
      if curr_state == 'noncontainer'
        steps = [:build, :create, :start]
      end
    when :reinstall
      if curr_state == 'stopped'
        steps = [:destroy, :build, :create, :start]
      else
        steps[0] = set_state
      end
    end
    STDERR.puts(" sterps #{steps} #{@last_task}")
    @last_task = steps[0]
  end

  def process_container_event(event_hash)
    expire_engine_info
    SystemDebug.debug(SystemDebug.container_events, :PROCESS_CONTAINER_vents, @container_name,  event_hash)
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
        ec = event_hash[:Actor][:Attributes][:exitCode]
      rescue
        ec = 0
      end
      on_stop('die', ec)
    when 'kill'
      status
      on_stop('kill')
    when 'stop'
      status
      on_stop('stop')
    when 'pause'
      status
      on_stop('pause')
    when 'oom'
      status
      out_of_mem('oom')
    when 'destroy'
      status
      on_destroy(event_hash)
    end
    true
  rescue StandardError => e
    log_exception(e)
  end

  def task_complete(action)
    container_mutex.synchronize {
      steps_to_go = 0 if steps_to_go.nil?
      #  SystemDebug.debug(SystemDebug.engine_tasks, :task_complete, ' ', action.to_s + ' as action for task ' +  task_at_hand.to_s + " " + @steps_to_go.to_s + '-1 stesp remaining step completed ',@steps)
      clear_task_at_hand
      # SystemDebug.debug(SystemDebug.builder, :last_task,  @last_task, :steps_to, @steps_to_go)
      return save_state unless last_task == :delete_image && steps_to_go <= 0
      # FixMe Kludge unless docker event listener
      #   SystemDebug.debug(SystemDebug.builder, :delete_engine,  @last_task, :steps_to, @steps_to_go)
      delete_engine
      true
    }
  end

  def task_at_hand
    fn = "#{store.container_state_dir(container_name)}/task_at_hand"
    if File.exist?(fn)
      thf = File.new(fn, 'r')
      begin
        @task_at_hand = thf.read
      ensure
        thf.close
      end
      unless @task_at_hand.nil?
        #   SystemDebug.debug(SystemDebug.containers, :task_at_hand_read_as, @task_at_hand)
        if task_has_expired?(@task_at_hand)
          expire_task_at_hand
          #     SystemDebug.debug(SystemDebug.containers, :task_at_hand_expired)
        elsif tasks_final_state(@task_at_hand) == read_state(raw = true)
          clear_task_at_hand
        else
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
  end

  def expire_task_at_hand
    #    SystemDebug.debug(SystemDebug.engine_tasks, 'expire Task ' + @task_at_hand.to_s )
    clear_task_at_hand
  end

  def clear_task_at_hand
    steps_to_go = 0 if steps_to_go.nil?
    steps_to_go -= 1 unless steps_to_go == 0
    if steps_to_go > 0
      #    SystemDebug.debug(SystemDebug.engine_tasks, 'Multistep Task ' + @task_at_hand.to_s )
      if steps.is_a?(Array)
        steps.pop(0)
        @task_at_hand = steps[0]
      end
      #  SystemDebug.debug(SystemDebug.engine_tasks, 'next Multistep Task ' + @task_at_hand.to_s)
      f = File.new("#{store.container_state_dir(container_name)}/task_at_hand",'w+')
      begin
        f.write(@task_at_hand.to_s)
      ensure
        f.close
      end
    else
      #   SystemDebug.debug(SystemDebug.engine_tasks, 'cleared Task ' + @task_at_hand.to_s)
      @task_at_hand = nil
      fn = "#{store.container_state_dir(container_name)}/task_at_hand"
      File.delete(fn) if File.exist?(fn)
    end
    @task_at_hand
  rescue StandardError => e
    STDERR.puts( ' clear task at hand ' + e.to_s + "\n" + e.backtrace.to_s)
    # well perhaps a perms or disk error but definitly not no such file
    #possbile exception such file (another process alsop got the eot mesg and removed)
    @task_at_hand
  end

  def task_failed(msg)
    clear_task_at_hand
    #   SystemDebug.debug(SystemDebug.engine_tasks, :TASK_FAILES______Doing, @task_at_hand)
    last_error = container_dock.last_error unless container_dock.nil?
    #  SystemDebug.debug(SystemDebug.engine_tasks, :WITH, @last_error.to_s, msg.to_s)
    task_complete(:failed)
    false
  end

  private

  def tasks_final_state(task)
    case task.to_sym
    when :create,:start,:recreate,:unpause,:restart,:rebuild,:build,:reinstall
        :running
    when :stop
        :stopped
    when :pause
         :paused
    when :delete,:destroy
     :nocontainer
    else
      STDERR.puts('UNKNOWN TASK ' + task.to_s)
      ''
    end
  end

  def task_has_expired?(task)
    fmtime = File.mtime("#{store.container_state_dir(container_name)}/task_at_hand")
    mtime = fmtime  + task_set_timeout(task)
    #  SystemDebug.debug(SystemDebug.container, mtime, fmtime, task, task_set_timeout(task))
    if mtime < Time.now
      File.delete("#{store.container_state_dir(container_name)}/task_at_hand")
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
    if Dir.exist?(store.container_state_dir(container_name)) # happens on reinstall
      f = File.new("#{store.container_state_dir(container_name)}/task_at_hand", 'w+')
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
