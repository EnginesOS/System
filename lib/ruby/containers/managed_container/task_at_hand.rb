module TaskAtHand
  @task_timeout=300
  def desired_state(state, curr_state)
    current_set_state = @setState
    @setState = state.to_s
    save_state

       if current_set_state ==  state.to_s
         return clear_task_at_hand
       else    
         set_task_at_hand(state)
       end 
       
       puts 'Task at Hand:' + state.to_s + '  Current set state:' + current_set_state.to_s + '  going for:' +  @setState  + ' with ' + @task_at_hand.to_s + ' in ' + curr_state
       return true
    rescue StandardError => e 
      log_exception(e)
  end

  def in_progress(action)
    p :in_p
    p action
    p action.class.name
    
    curr_state = read_state
    case action
    when :create      
      return desired_state('running', curr_state) if curr_state== 'nocontainer' 
    when :stop
      return desired_state('stopped', curr_state) if curr_state== 'running'
    when :start
      return desired_state('running', curr_state) if curr_state== 'stopped'
    when :pause
      return desired_state('paused', curr_state) if curr_state== 'running'
    when :restart
      return desired_state('stopped', curr_state) if curr_state== 'running'
    when :unpause
      return desired_state('running', curr_state) if curr_state== 'paused'
    when :recreate
      return desired_state('running', curr_state) if curr_state== 'stopped' || curr_state== 'nocontainer'
    when :rebuild
      return desired_state('running', curr_state) if curr_state== 'stopped' || curr_state== 'nocontainer'
    when :build
      return desired_state('running', curr_state) if curr_state== 'nocontainer'
    when :delete
      return desired_state('nocontainer', curr_state) if curr_state== 'stopped'
      #  desired_state('noimage')
    when :destroy
      return desired_state('nocontainer', curr_state) if curr_state== 'stopped' || curr_state== 'nocontainer'
    end
   
    if tasks_final_state(action) == curr_state
      puts 'already their'
      @setState = curr_state
      save_state
      return curr_state
      # sync gui with relaty it started but then stopped before gui updated
    else
      puts 'Cant take from ' +  curr_state.to_s + ' to ' + action.to_s
      puts 'curr_state is a ' + curr_state.class.name + ' action is a ' + action.class.name
      puts 'and finale state is ' + tasks_final_state(action)
    end
    return log_error_mesg('not in matching state want _' + tasks_final_state(action).to_s + '_but in ' + curr_state.class.name + ' ',curr_state.to_s )
     
    
    # Perhaps ?return clear_task_at_hand
    rescue StandardError => e 
      log_exception(e)
  end

  def task_complete(action)
    @last_task =  task_at_hand
    p :task_complete
    clear_task_at_hand
    expire_engine_info
    p :last_task
    p @last_task
    save_state unless @last_task == :delete
    # FixMe Kludge unless docker event listener
    ContainerStateFiles.delete_container_configs(container) if @last_task == :delete
    return true
    rescue StandardError => e 
      log_exception(e)
  end



  def task_at_hand
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    return nil unless File.exist?(fn)
   return nil if task_has_expired?
    task = File.read(fn)
     r = read_state(raw=true)
    if tasks_final_state(task) == r
      clear_task_at_hand
      return nil
    end
    task
  rescue StandardError => e 
    log_exception(e)
    return nil
   # @task_at_hand 
  end

  def clear_task_at_hand
    @task_at_hand = nil
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    File.delete(fn) if File.exist?(fn)
    rescue StandardError => e 
    log_exception(e)
    return true  #possbile exception such file (another process alsop got the eot mesg and removed) 
  end
  
  def wait_for_task(timeout=25)
    loops=0
    p :wait_for_task
    p task_at_hand
    while ! task_at_hand.nil?
      sleep(0.5)
      loops+=1
      p :wft_loop
      p task_at_hand
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
    p :TASK_FAILES______Doing
    p @task_at_hand

    @last_error = @container_api.last_error unless @container_api.nil?
    p :WITH
    p @last_error.to_s
    p msg.to_s
    task_complete(:failed)
    return false
  rescue StandardError => e 
    log_exception(e)
  end
  
  def wait_for_container_task(timeout=30)
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
        when :recreate
          return    'running'
        when :rebuild
          return    'running'
        when :build
          return    'running'
        when :delete
          return    'nocontainer'
        when :destroy
          return   'destroyed'
        end
    rescue StandardError => e 
      log_exception(e)
  end
   
  private
  
  def task_has_expired?
    mtime = File.mtime(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
    mtime += @task_timeout
    if mtime < Time.now
      File.delete(ContainerStateFiles.container_state_dir(self) + '/task_at_hand')
      return true
    end
    return false
    # no file problem with mtime etc means task has finished in progress and task file has dissapppeared
  rescue
    return true 
  end
  
  def set_task_at_hand(state)
p :set_taskah
    @task_at_hand = state
    f = File.new(ContainerStateFiles.container_state_dir(self) + '/task_at_hand','w+')
    f.write(state)
    f.close
    # clear task if still there after 60 s
#    Thread.new do
#      begin
#       return if wait_for_container_task(60)         
#        clear_task_at_hand
#      ensure
#        clear_task_at_hand
#      end     
#    end
    rescue StandardError => e 
      log_exception(e)
  end
end