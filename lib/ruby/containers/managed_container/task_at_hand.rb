module TaskAtHand
  def desired_state(state)
    @setState = state
    save_state
  end

  def in_progress(state)
    set_task_at_hand(state)

    current_state = @setState
    case state
    when :create
      desired_state('running')
    when :stop
      desired_state('stopped')
    when :start
      desired_state('running')
    when :pause
      desired_state('paused')
    when :restart
      desired_state('stopped')
    when :unpause
      desired_state('running')
    when :recreate
      desired_state('nocontainer')
    when :rebuild
      desired_state('nocontainer')
    when :build
      desired_state('running')
    when :delete
      desired_state('nocontainer')
      #  desired_state('noimage')
    when :destroy
      desired_state('nocontainer')
    end
    STDERR.puts 'Task at Hand:' + state.to_s + '  Current state:' + current_state.to_s + '  going for:' + @task_at_hand.to_s
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

  def set_task_at_hand(state)

    @task_at_hand = state
    f = File.new(ContainerStateFiles.container_state_dir(self) + '/task_at_hand','w+')
    f.write(state)
    f.close

  end

  def task_at_hand
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    return nil unless File.exist?(fn)
    p :read_tah
p     File.read(fn)
    @task_at_hand 
  end

  def clear_task_at_hand
    @task_at_hand = nil
    fn = ContainerStateFiles.container_state_dir(self) + '/task_at_hand'
    File.delete(fn) if File.exist?(fn)
  end

  def task_failed(msg)
    p :TASK_FAILES______Doing
    p @task_at_hand

    @last_error = @container_api.last_error
    p :WITH
    p @last_error.to_s
    p msg.to_s
    task_complete
    return false
  end
end