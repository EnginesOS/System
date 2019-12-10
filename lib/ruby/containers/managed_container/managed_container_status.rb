module ManagedContainerStatus
  def is_service?
    if ctype == 'service'
      true
    else
      false
    end
  end

  def read_state
    state = super
    SystemDebug.debug(SystemDebug.containers, container_name, "Super state #{state}")
    if state == 'na'
      expire_engine_info
        SystemDebug.debug(SystemDebug.containers, container_name, 'in na',  :info)
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
    if docker_info.nil?
      self.state = :nocontainer
    else
      self.state = super()
      if state.nil? #Kludge
        self.state = :nocontainer
        self.last_error = 'mc got nil from super in read_state'
      end
    end
    unless raw == true
      if self.state != set_state && task_at_hand.nil?
        self.last_error =  "Warning State Mismatch set to #{set_state} but in #{state} state"
      else
        self.last_error = ''
      end
    end
    self.state
  rescue EnginesException =>e
    expire_engine_info
    :nocontainer
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
        r = true if set_state == read_state
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
    self.out_of_memory = false
    self.had_out_memory = false
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
#
#  def container_id   
#     unless set_state == :nocontainer
#       self.id = read_container_id if id.nil?
#     end  
#    id
#  end

  protected

  def save_state
    status
    container_dock.save_container(self)
  end

end
