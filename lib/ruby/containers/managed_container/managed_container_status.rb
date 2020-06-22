module ManagedContainerStatus
  def is_service?
    if @ctype == 'service'
      true
    else
      false
    end
  end

  #
  def save_state
    status
    container_api.save_container(self.dup)
  end

  def read_state
    state = super
    if state == 'na'
      expire_engine_info
      #  SystemDebug.debug(SystemDebug.containers, container_name, 'in na',  :info)
      :nocontainer
    else
      state
    end
  rescue EnginesException =>e
    expire_engine_info
    :nocontainer
  end

  def is_privileged?
    false
  end

  # raw=true means dont check state for error
  def read_state(raw = false)
    if docker_info.is_a?(FalseClass)
      state = :nocontainer
    else
      state = super()
      if state.nil? #Kludge
        state = :nocontainer
        @last_error = 'mc got nil from super in read_state'
      end
    end
    unless raw == true
      if state != @set_state && task_at_hand.nil?
        @last_error =  "Warning State Mismatch set to #{@set_state} but in #{state} state"
      else
        @last_error = ''
      end
    end
    state
  rescue EnginesException =>e
    expire_engine_info
    :nocontainer
    clear_cid
    raise e
  end

  def is_startup_complete?
    ContainerStateFiles.is_startup_complete?(store_address)
  end

  def is_error?(cs)
    r = false
    
    if cs != @set_state
      STDERR.puts('set ERRRPR')
      r = true unless task_at_hand.nil?
    end
    r = false if cs == :stopped && is_stopped_ok?
    STDERR.puts("Is container #{@container_name} error = #{r}  cs = #{cs} #{cs.class.name} set State = #{@set_state} and stopped ok #{is_stopped_ok?} tah #{task_at_hand}")
    r
  rescue StandardError => e
    log_exception(e)
    true
    #  Bit of a primative solution
    #  what if doing the delete stag of a recreat? when in_two_step? with more tasks to do
    # how do you time out a crashed multi step
  end

  def set_debug
    ContainerStateFiles.set_debug(store_address)
  end

  def clear_debug
    ContainerStateFiles.clear_debug(store_address)
  end

  def clear_error
    #Sychronise somewhere
    @out_of_memory = false
    @had_out_memory = false
    save_state
    true
  end

  def restart_required?
    ContainerStateFiles.restart_required?(store_address)
  end

  def restart_reason
    ContainerStateFiles.restart_reason(store_address)
  end

  def rebuild_required?
    ContainerStateFiles.rebuild_required?(store_address)
  end

  def rebuild_reason
    ContainerStateFiles.rebuild_reason(store_address)
  end

  def in_two_step?
    File.exist?("#{ContainerStateFiles.container_state_dir(store_address)}/in_progress")
  end

  def container_id
    if @id == -1 || @id.nil?
      @id = read_container_id
    end
    @id
  end

end