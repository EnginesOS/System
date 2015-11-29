module TaskAtHand
  def desired_state(state, si)
    current_set_state = @setState
    @setState = state
    save_state

       if si ==  state
         return clear_task_at_hand
       else    
         set_task_at_hand(state)
       end 
       
       STDERR.puts 'Task at Hand:' + state.to_s + '  Current set state:' + current_set_state.to_s + '  going for:' +  @setState  + ' with ' + @task_at_hand.to_s + ' in ' + si
  end

  def in_progress(state)
  
    si = read_state

   
    case state
    when :create      
      return desired_state('running', si) if si == 'nocontainer' 
    when :stop
      return   desired_state('stopped', si) if si == 'running'
    when :start
      return   desired_state('running', si) if si == 'stopped'
    when :pause
      return  desired_state('paused', si) if si == 'running'
    when :restart
      return   desired_state('stopped', si) if si == 'running'
    when :unpause
      return   desired_state('running', si) if si == 'paused'
    when :recreate
      return   desired_state('running', si) if si == 'stopped' || si == 'nocontainer'
    when :rebuild
      return   desired_state('running', si) if si == 'stopped' || si == 'nocontainer'
    when :build
      return   desired_state('running', si) if si == 'nocontainer'
    when :delete
      return   desired_state('nocontainer', si) if si == 'stopped'
      #  desired_state('noimage')
    when :destroy
      return   desired_state('nocontainer', si) if si == 'nocontainer'
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
    #DONT SET IF ALREASDY THERE
    
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    return nil unless File.exist?(fn)
    
    p :read_tah
    task = File.read(fn)
     
    if tasks_final_state(task) == read_state
      clear_task_at_hand
      return nil
    end
     puts '_' + task.to_s + '_'
    task
   # @task_at_hand 
  end

  def clear_task_at_hand
    @task_at_hand = nil
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    File.delete(fn) if File.exist?(fn)
     p :Clear_Task
     return true
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
    case state
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
  end
   
  private
  def set_task_at_hand(state)
p :set_taskah
    @task_at_hand = state
    f = File.new(ContainerStateFiles.container_state_dir(self) + '/task_at_hand','w+')
    f.write(state)
    f.close
    Thread.new { wait_for_container_task }
  end
end