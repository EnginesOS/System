module ManagedContainerStatus
  def is_service?
    if @ctype == 'service'
      true
    else
      false
    end
  end

  def read_state
    state = super
    if state == 'na'
      expire_engine_info
      SystemDebug.debug(SystemDebug.containers, container_name, 'in na',  :info)
      'nocontainer'
    else
      state
    end
  rescue EnginesException =>e
    expire_engine_info
    'nocontainer'
  end

  def is_privileged?
    false
  end

  # raw=true means dont check state for error
  def read_state(raw = false)
    if docker_info.is_a?(FalseClass)
      state = 'nocontainer'
    else
      state = super()
      if state.nil? #Kludge
        state = 'nocontainer'
        @last_error = 'mc got nil from super in read_state'
      end
    end
    unless raw == true
      if state != @setState && task_at_hand.nil?
        @last_error =  ' Warning State Mismatch set to ' + @setState.to_s + ' but in ' + state.to_s + ' state'
      else
        @last_error = ''
      end
    end
    state
  rescue EnginesException =>e
    expire_engine_info
    'nocontainer'
    clear_cid
    raise e
  end

  def is_startup_complete?
    @container_api.is_startup_complete?(self)
  end

  def is_error?
    r = false
    if task_at_hand.nil?
      if in_two_step?
        r = true if @setState == read_state
      end
    end
    r
  end

  def clear_error
    @out_of_memory = false
    @had_out_memory = false
    save_state
    true
  end

  def restart_required?
    @container_api.restart_required?(self)
  end

  def restart_reason
    @container_api.restart_reason(self)
  end

  def rebuild_required?
    @container_api.rebuild_required?(self)
  end

  def rebuild_reason
    @container_api.rebuild_reason(self)
  end

  def in_two_step?
    File.exist?(ContainerStateFiles.container_state_dir(self) + '/in_progress')
  end

end