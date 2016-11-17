module ContainerControls
  def start_container
    #expire_engine_info
    r = true
    return true if read_state == 'running'
    return log_error_mesg('Can\'t Start Container as ', self) unless read_state == 'stopped'
    r  =  @container_api.start_container(self)
    expire_engine_info
    return  r   
  end

  def stop_container
    #expire_engine_info
    r = true
    return true if read_state == 'stopped'
    return log_error_mesg('Can\'t Stop Container as ', self) unless read_state == 'running'
    r =  @container_api.stop_container(self)
    expire_engine_info
    return  r   
  end

  def pause_container
    #expire_engine_info
    r = true
    return true if read_state == 'paused'
    return log_error_mesg('Can\'t Pause Container as not running', self) unless is_running?
    r  =  @container_api.pause_container(self)
    expire_engine_info
    return r  
  end

  def unpause_container
    #expire_engine_info
    r = true
    return true if read_state == 'running'
    return log_error_mesg("Can\'t unpause as not paused", self) unless is_paused?
    r =  @container_api.unpause_container(self)
    expire_engine_info
    return r
  end

  def destroy_container()
    expire_engine_info
    r = true
    if read_state == 'nocontainer'
      @container_id = '-1'
      return true
    end
    return  log_error_mesg('Cannot Destroy a container that is not stopped Please stop first', self) if is_active?
    r = @container_api.destroy_container(self)
    @container_id = '-1'
    expire_engine_info
    return r   
  end

  def create_container
    expire_engine_info
    return log_error_mesg('Cannot create container as container exists ', self) if has_container?
    @container_id = -1
  r = @container_api.create_container(self)
    SystemDebug.debug(SystemDebug.containers,  :create_container,:containerid,r)
    return r
  rescue => e
    log_exception(e)
  end
end