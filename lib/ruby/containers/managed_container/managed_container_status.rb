module ManagedContainerStatus
  def is_service?
    return true if @ctype == 'service'
    return false
  end

  def read_state
    #return 'nocontainer' if @setState == 'nocontainer'  # FIXME: this will not support notification of change
    if docker_info.is_a?(FalseClass)
      #log_error_mesg('Failed to inspect container', self) not an error just no image
      state = 'nocontainer'
    else
      state = super
      if state.nil? #Kludge
        state = 'nocontainer'
        @last_error = 'state nil'
      end
    end
    if state != @setState && @task_at_hand.nil?
      @last_error =  ' Warning State Mismatch set to ' + @setState.to_s + ' but in ' + state.to_s + ' state'
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
    return false unless @task_at_hand.nil?
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

end