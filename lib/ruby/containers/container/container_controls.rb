module ContainerControls
  def start_container
    expire_engine_info
   # r = true
    return true if is_running?
    raise EnginesException.new(warning_hash("Can\'t Start " + container_name + ' as is ' + read_state.to_s, container_name)) unless read_state == 'stopped'
    #r = 
    @container_api.start_container(self)
  ensure
    expire_engine_info
    #r
    false
  end

  def halt_container
    #stop_container dont want the managedcontainer stuff run
    expire_engine_info
      #  r = true
        return true if is_stopped?        
        raise EnginesException.new(warning_hash("Can\'t Stop " + container_name + ' as is ' + read_state.to_s, container_name)) unless read_state == 'running'
        @container_api.stop_container(self)
      ensure
        expire_engine_info
        false
  end

  def stop_container
    expire_engine_info
 #   r = true
    return true if is_stopped?
    raise EnginesException.new(warning_hash("Can\'t Stop " + container_name + ' as is ' + read_state.to_s, container_name)) unless read_state == 'running'
    @container_api.stop_container(self)
  ensure
    expire_engine_info
    false
  end
  
  def wait_for(what, timeout = 10)
    @container_api.wait_for(self, what, timeout)
  end

  def pause_container
    expire_engine_info
    # r = true
    return true if is_paused?
    raise EnginesException.new(warning_hash("Can\'t Pause " + container_name + ' as is ' + read_state.to_s, container_name)) unless is_running?
    #r =
    @container_api.pause_container(self)
  ensure
    expire_engine_info
    false
    # r
  end

  def unpause_container
    expire_engine_info
    #r = true
    return true if is_running?
    raise EnginesException.new(warning_hash("Can\'t unpause " + container_name + ' as is ' + read_state.to_s, container_name)) unless is_paused?
   # r =
    @container_api.unpause_container(self)
  ensure
    expire_engine_info
  #  r
    false
  end

  def destroy_container() 
    expire_engine_info
    unless has_container?
      @container_id = '-1'
      return true
    end
    raise EnginesException.new(warning_hash('Cannot Destroy ' +  container_name + ' as is not stopped Please stop first', container_name)) if is_active?
    r =  container_api.destroy_container(self)
  ensure
    @container_id = '-1'
    expire_engine_info
    r
  end

  def create_container
    expire_engine_info
    SystemDebug.debug(SystemDebug.containers,  :create_container,:containerid)
    raise EnginesException.new(warning_hash('Cannot create container as container exists ', container_name)) if has_container?
    @container_id = -1
    @container_api.create_container(self)
  end
end