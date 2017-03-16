module ContainerControls
  def start_container
    #expire_engine_info
    r = true
    return true if read_state == 'running'
    raise EnginesException.new(warning_hash('Can\'t Start Container as ', self)) unless read_state == 'stopped'
    r  =  @container_api.start_container(self)
    expire_engine_info
      r   
  end
  def halt_container
    stop_container
  end

  def stop_container
    #expire_engine_info
    r = true
    return true if read_state == 'stopped'
    raise EnginesException.new(warning_hash('Can\'t Stop Container as ', self)) unless read_state == 'running'
    r =  @container_api.stop_container(self)
    expire_engine_info
      r   
  end

  def pause_container
    #expire_engine_info
    r = true
    return true if read_state == 'paused'
    raise EnginesException.new(warning_hash('Can\'t Pause Container as not running', self)) unless is_running?
    r  =  @container_api.pause_container(self)
    expire_engine_info
     r  
  end

  def unpause_container
    #expire_engine_info
    r = true
    return true if read_state == 'running'
    raise EnginesException.new(warning_hash("Can\'t unpause as not paused", self)) unless is_paused?
    r =  @container_api.unpause_container(self)
    expire_engine_info
     r
  end

  def destroy_container()
    expire_engine_info
    r = true
    if read_state == 'nocontainer'
      @container_id = '-1'
      return true
    end
    raise EnginesException.new(warning_hash('Cannot Destroy a container that is not stopped Please stop first', self)) if is_active?
    r = @container_api.destroy_container(self)
    @container_id = '-1'
    expire_engine_info
     r   
  end

  def create_container
    expire_engine_info
    raise EnginesException.new(warning_hash('Cannot create container as container exists ', self)) if has_container?
    @container_id = -1
  r = @container_api.create_container(self)
    SystemDebug.debug(SystemDebug.containers,  :create_container,:containerid,r)
     r
  rescue => e
    log_exception(e)
  end
end