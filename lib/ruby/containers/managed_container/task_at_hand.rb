module TaskAtHand
  def desired_state(state)
    @setState = state
    save_state
  end

  def in_progress(state)
    @task_at_hand = state
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
    STDERR.puts 'Task at Hand:' + state.to_s + ' Current state' + current_state.to_s + ' going for ' + @task_at_hand.to_s
  end

  def task_complete
    @last_task =  @task_at_hand
    @task_at_hand = nil
    expire_engine_info
    save_state
    return true
  end

  def task_failed(msg)
    p :task_failed
    p @task_at_hand
    @last_error = @container_api.last_error
    p msg.to_s
    task_complete
    return false
  end
end