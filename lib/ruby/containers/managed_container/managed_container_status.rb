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
      #  SystemDebug.debug(SystemDebug.containers, container_name, 'in na',  :info)
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
        @last_error =  "Warning State Mismatch set to #{@setState} but in #{state} state"
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
    store.is_startup_complete?(container_name)
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

  def set_debug
    store.set_debug(store_address)
  end

  def clear_debug
    store.clear_debug(store_address)
  end

  def clear_error
    #Sychronise somewhere
    @out_of_memory = false
    @had_out_memory = false
    save_state
    true
  end

  def restart_required?
    store.restart_required?(store_address)
  end

  def restart_reason
    store.restart_reason(store_address)
  end

  def rebuild_required?
    store.rebuild_required?(store_address)
  end

  def rebuild_reason
    store.rebuild_reason(store_address)
  end

  def in_two_step?
    File.exist?("#{store.container_state_dir(container_name)}/in_progress")
  end

  def container_id
    if @id.nil?
      @id = read_container_id
    end
    @id
  end

  protected

  def save_state
    status
    container_dock.save_container(self)
  end

end
