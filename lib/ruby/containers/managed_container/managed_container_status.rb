module ManagedContainerStatus
  def is_service?
    return true if @ctype == 'service'
    return false
  end
  
  
# raw=true means dont check state for error
  def read_state(raw=false)
    #return 'nocontainer' if @setState == 'nocontainer'  # FIXME: this will not support notification of change
    if docker_info.is_a?(FalseClass)
     # p :info_false
      #log_error_mesg('Failed to inspect container', self) not an error just no image
      state = 'nocontainer'
    else
      state = super()
      if state.nil? #Kludge
        state = 'nocontainer'
        @last_error = 'mc got nil from super in read_state'
      end
    end
    return state if raw == true
    
    if state != @setState && task_at_hand.nil?     
      @last_error =  ' Warning State Mismatch set to ' + @setState.to_s + ' but in ' + state.to_s + ' state'
    else
      @last_error = ''
    end
    return state
  rescue Exception=>e
    p @last_result
    log_exception(e)
    return 'nocontainer'
  end

  def is_startup_complete?
    return false unless has_api?
    @container_api.is_startup_complete(self)
  end

  def is_error?    
    return false unless task_at_hand.nil? 
    return false if in_two_step?
    state = read_state
    return true if @setState != state
    return false
  end

  def restart_required?
    return false unless has_api?
    @container_api.restart_required?(self)
  end

  def restart_reason
    return false unless has_api?
    @container_api.restart_reason(self)
  end

  def rebuild_required?
    return false unless has_api?
    @container_api.rebuild_required?(self)
  end

  def rebuild_reason
    return false unless has_api?
    @container_api.rebuild_reason(self)
  end
  
  def in_two_step?
    return File.exist?(ContainerStateFiles.container_state_dir(self) + '/in_progress')
  end

end