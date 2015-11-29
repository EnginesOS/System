module TaskAtHand
  def desired_state(state, curr_state)
    current_set_state = @setState
    @setState = state
    save_state

       if curr_state ==  state
         return clear_task_at_hand
       else    
         set_task_at_hand(state)
       end 
       
       STDERR.puts 'Task at Hand:' + state.to_s + '  Current set state:' + current_set_state.to_s + '  going for:' +  @setState  + ' with ' + @task_at_hand.to_s + ' in ' + curr_state
  end

  def in_progress(action)
  
    curr_state= read_state

   
    case action
    when :create      
      return desired_state('running', curr_state) if curr_state== 'nocontainer' 
    when :stop
      return   desired_state('stopped', curr_state) if curr_state== 'running'
    when :start
      return   desired_state('running', curr_state) if curr_state== 'stopped'
    when :pause
      return  desired_state('paused', curr_state) if curr_state== 'running'
    when :restart
      return   desired_state('stopped', curr_state) if curr_state== 'running'
    when :unpause
      return   desired_state('running', curr_state) if curr_state== 'paused'
    when :recreate
      return   desired_state('running', curr_state) if curr_state== 'stopped' || curr_state== 'nocontainer'
    when :rebuild
      return   desired_state('running', curr_state) if curr_state== 'stopped' || curr_state== 'nocontainer'
    when :build
      return   desired_state('running', curr_state) if curr_state== 'nocontainer'
    when :delete
      return   desired_state('nocontainer', curr_state) if curr_state== 'stopped'
      #  desired_state('noimage')
    when :destroy
      return   desired_state('nocontainer', curr_state) if curr_state== 'nocontainer'
    end
    # Perhaps ?return clear_task_at_hand
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
  end



  def task_at_hand
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    return nil unless File.exist?(fn)
    task = File.read(fn)
     r = read_state(raw=true)
    if tasks_final_state(task) == r 
      clear_task_at_hand
      return nil
    end
    task
  rescue StandardError
    return nil
   # @task_at_hand 
  end

  def clear_task_at_hand
    @task_at_hand = nil
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    File.delete(fn) if File.exist?(fn)
    rescue StandardError
    return true  #posbile exception such file (another process alsop got the eot mesg and removed) 
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
    rescue StandardError
      return false
  end

  def task_failed(msg)
    clear_task_at_hand
    p :TASK_FAILES______Doing
    p @task_at_hand

    @last_error = @container_api.last_error
    p :WITH
    p @last_error.to_s
    p msg.to_s
    task_complete(:failed)
    return false
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
          return    'nocontainer'
        when :build
          return    'running'
        when :delete
          return    'nocontainer'
        when :destroy
          return   'destroyed'
        end
  end
   
  private
  def set_task_at_hand(state)
p :set_taskah
    @task_at_hand = state
    f = File.new(ContainerStateFiles.container_state_dir(self) + '/task_at_hand','w+')
    f.write(state)
    f.close
    # clear task if still there after 60 s
    Thread.new do
      clear_task_at_hand  unless wait_for_container_task(60) 
      
    end
  end
end