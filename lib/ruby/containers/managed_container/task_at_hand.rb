module TaskAtHand
  @default_task_timeout = 20
  @task_queue = []
  
     
  def init_task_at_hand
    @steps = [] 
  end
    
  def desired_state(step, state, curr_state)
    current_set_state = @setState
    @setState = state.to_s   

   set_task_at_hand(step)
   save_state
#       end 
       
    SystemDebug.debug(SystemDebug.engine_tasks,  'Task at Hand:' + state.to_s + '  Current set state:' + current_set_state.to_s + '  going for:' +  @setState  + ' with ' + @task_at_hand.to_s + ' in ' + curr_state)
       return true
    rescue StandardError => e 
      log_exception(e)
  end

  def in_progress(action)
    step = action
    if @steps_to_go.nil? || @steps_to_go <= 0
      @steps_to_go = 1    
      @steps = [] 
      @steps[0] = action 
    end
    curr_state = read_state
    SystemDebug.debug(SystemDebug.engine_tasks, :read_state, curr_state)
    # FIX ME Finx the source 0 :->:
    curr_state.sub!(/\:->\:/,'')
  @last_task = action
    case action
    when :create      
      return desired_state(step, 'running', curr_state) if curr_state== 'nocontainer' 
    when :stop
      return desired_state(step, 'stopped', curr_state) if curr_state== 'running'
    when :start
      return desired_state(step, 'running', curr_state) if curr_state== 'stopped'
    when :pause
      return desired_state(step, 'paused', curr_state) if curr_state== 'running'
    when :restart
      if curr_state == 'running'
      @steps = [:stop,:start]
      @steps_to_go = 2
      return desired_state(step, 'stopped', curr_state) 
    end
      return desired_state(step, 'running', curr_state)
    when :unpause
      return desired_state(step, 'running', curr_state) if curr_state== 'paused'
    when :recreate
      if curr_state== 'stopped'
        @steps = [:destroy,:create]
        @steps_to_go = 2 
        return desired_state(step, 'running', curr_state)
      end      
      return desired_state(step, 'running', curr_state) if  curr_state== 'nocontainer'
     
    when :rebuild
      
      if curr_state== 'stopped'
            @steps = [:destroy,:create]
            @steps_to_go = 2
            return desired_state(step, 'running', curr_state) 
          end      
     
    
      return desired_state(step, 'running', curr_state) if  curr_state== 'nocontainer'
      
      when :reinstall
      if curr_state== 'stopped'
              @steps =  [:destroy,:create]
              @steps_to_go = 2
              return desired_state(step, 'running', curr_state)
            end            
      @steps_to_go = 2
          return desired_state(step, 'running', curr_state) if  curr_state== 'nocontainer'
    when :build
      return desired_state(step, 'running', curr_state) if curr_state== 'nocontainer'
    when :delete
      return desired_state(step, 'nocontainer', curr_state) if curr_state== 'stopped'
      #  desired_state(@steps, 'noimage')
    when :destroy
      return desired_state(step, 'nocontainer', curr_state) if curr_state== 'stopped' || curr_state== 'nocontainer'
    end
    
    return log_error_mesg('not in matching state want _' + tasks_final_state(action).to_s + '_but in ' + curr_state.class.name + ' ',curr_state )
   
  
    
    # Perhaps ?return clear_task_at_hand
    rescue StandardError => e 
      log_exception(e)
  end

  def task_complete(action)
    expire_engine_info
    return if action == 'create'
    

    SystemDebug.debug(SystemDebug.engine_tasks, :task_complete, ' ', action.to_s + ' as action for task ' +  task_at_hand.to_s + " " + @steps_to_go.to_s + 'steps to go ',@steps) 

    clear_task_at_hand    
    SystemDebug.debug(SystemDebug.builder, :last_task,   @last_task)
   return save_state unless @last_task == :delete && @steps_to_go == 0
    # FixMe Kludge unless docker event listener
    ContainerStateFiles.delete_container_configs(container) 
    return true
    rescue StandardError => e 
      log_exception(e)
  end



  def task_at_hand
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    return nil unless File.exist?(fn)
 
    task = File.read(fn)
    if task_has_expired?(task)
      expire_task_at_hand
      return nil
    end
    
     r = read_state(raw=true)
    if tasks_final_state(task) == r
      clear_task_at_hand
      return nil
    end
    task
  rescue StandardError => e 
    return nil unless File.exist?(fn)
    log_exception(e)
    return nil
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
    return true  #possbile exception such file (another process alsop got the eot mesg and removed) 
  end
  
  def wait_for_task(task)
    loops=0
    timeout = task_set_timeout(task)
  #  p :wait_for_task
    SystemDebug.debug(SystemDebug.engine_tasks,  :wait_for_task, task_at_hand)
    
   return true if task_at_hand.nil?
      
      fmtime = File.mtime(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
      while   fmtime ==   File.mtime(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
      sleep(0.5)
      loops+=1
      SystemDebug.debug(SystemDebug.engine_tasks, :wft_loop, ' ', task_at_hand)
      if loops > timeout * 2
        return false
      end
    end
    return true
    rescue StandardError => e 
    log_exception(e)
      return false
  end

  def task_failed(msg)
    clear_task_at_hand
    SystemDebug.debug(SystemDebug.engine_tasks,:TASK_FAILES______Doing, @task_at_hand)

    @last_error = @container_api.last_error unless @container_api.nil?
    SystemDebug.debug(SystemDebug.engine_tasks, :WITH, @last_error.to_s, msg.to_s)
    task_complete(:failed)
    return false
  rescue StandardError => e 
    log_exception(e)
  end
  
  def wait_for_container_task(timeout=90)
     fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
      return true unless File.exist?(fn)
      loop = 0
      while File.exist?(fn) 
        sleep(0.5)
        loop += 1
         return false if loop > timeout * 2
      end
      return true
    rescue StandardError => e 
      log_exception(e)
   end
   
  
  private
  
  def tasks_final_state(task)
      case task
          when :create      
            return 'running'
          when :stop
            return  'stopped'
          when :start
            return    'running'
          when :pause
            return   'paused'
          when :restart
            return    'stopped'
          when :unpause
            return    'running'
          when :reinstall
            return    'running'  
          when :recreate
            return    'running'
          when :rebuild
            return    'running'
          when :build
            return    'running'
          when :delete
            return  'nocontainer'
          when :destroy
            return   'destroyed'
          end
      rescue StandardError => e 
        log_exception(e)
    end
     
  def task_has_expired?(task)
    fmtime = File.mtime(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')          
    mtime = fmtime  + task_set_timeout(task)
    if mtime < Time.now
      File.delete(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
      return true
    end
    return false
    # no file problem with mtime etc means task has finished in progress and task file has dissapppeared
  rescue StandardError => e
    SystemDebug.debug(SystemDebug.engine_tasks, e, e.backtrace)
    return true 
  end
  
  def task_set_timeout(task)
    @default_task_timeout = 20
    @task_timeouts = {}
    @task_timeouts[task.to_sym] =  @default_task_timeout  unless @task_timeouts.key?(task.to_sym)
    @task_timeouts[:stop]= 60
    @task_timeouts[:start]= 30
    @task_timeouts[:restart]= 60
    @task_timeouts[:recreate]= 90
    @task_timeouts[:create]= 90
    @task_timeouts[:build]= 300
    @task_timeouts[:rebuild]= 120
    @task_timeouts[:pause]= 20
    @task_timeouts[:unpause]= 20
    @task_timeouts[:destroy]= 30
    @task_timeouts[:delete]= 40
  @task_timeouts[:running]= 40
  #  SystemDebug.debug(SystemDebug.engine_tasks, :timeout_set_for_task,task.to_sym, @task_timeouts[task.to_sym].to_s + 'secs')
# return  @default_task_timeout
   return @task_timeouts[task.to_sym]
  end
  
  def set_task_at_hand(state)
    @task_at_hand = state
    f = File.new(ContainerStateFiles.container_state_dir(self) + '/task_at_hand','w+')
    f.write(state)
    f.close
    rescue StandardError => e 
      log_exception(e)
  end
end