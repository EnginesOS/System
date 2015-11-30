module ContainerControls
  def start_container
   # expire_engine_info
    r = true
    return true if read_state == 'running'
    return log_error_mesg('Can\'t Start Container as ', self) unless read_state == 'stopped'
    r  = false unless @container_api.start_container(self)
 #   expire_engine_info
    return true if r
    return log_error_mesg('Can\'t Start Container', @container_api.last_error)
  end

  def stop_container
   # expire_engine_info
    r = true
    return true if read_state == 'stopped' 
    return log_error_mesg('Can\'t Stop Container as ', self) unless read_state == 'running'
    r = false  unless @container_api.stop_container(self)
  #  expire_engine_info
    return true if r
    return log_error_mesg('Can\'t Stop Container', @container_api.last_error)
  end

  def pause_container
  #  expire_engine_info
    r = true
    return true if read_state == 'paused'
    return log_error_mesg('Can\'t Pause Container as not running', self) unless is_running?
    r  = false unless @container_api.pause_container(self)
   # expire_engine_info
    return true if r
    return log_error_mesg('Can\'t Pause Container', @container_api.last_error)
  end

  def unpause_container
   # expire_engine_info
    r = true
    return true if read_state == 'running'
    return log_error_mesg('Can\'t  unpause as no paused', self) unless is_paused?
    r = false unless @container_api.unpause_container(self)
    #expire_engine_info
    return true if r
    return log_error_mesg('Can\'t UnPause Container', @container_api.last_error)
  end

  def destroy_container
  #  expire_engine_info
    r = true
    return true if read_state == 'nocontainer'
    return  log_error_mesg('Cannot Destroy a container that is not stopped Please stop first', self) if is_active?
    r = false unless @container_api.destroy_container(self)
    @container_id = '-1'
  #  expire_engine_info
    return true if r
    return log_error_mesg('Can\'t Destroy Container', @container_api.last_error)
  end

  def create_container
    #expire_engine_info
    return log_error_mesg('Cannot create container as container exists ', self) if has_container?
    if @container_api.create_container(self)
      expire_engine_info
      @container_id = read_container_id
      @cont_userid = running_user
   #   expire_engine_info
      return true
    end
    @container_id = -1
    @cont_userid = ''
    return false
  rescue => e
    log_exception(e)
  end
end