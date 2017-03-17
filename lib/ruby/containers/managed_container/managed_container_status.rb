module ManagedContainerStatus
  def is_service?
    return true if @ctype == 'service'
    return false
  end
  
  def read_state
    state = super
   
    if state == 'na'     
      expire_engine_info
      SystemDebug.debug(SystemDebug.containers, container_name,'in na',  :info, @docker_info_cache)
      return 'nocontainer'
    end
    
     state
  rescue EnginesException =>e
    expire_engine_info
    'nocontainer'
  end
  
# raw=true means dont check state for error
  def read_state(raw=false)
    #return 'nocontainer' if @setState == 'nocontainer'  # FIXME: this will not support notification of change
    if docker_info.is_a?(FalseClass)
     
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
     state
#  rescue Exception=>e
#    STDERR.puts 'excetpion ' + e.to_s + ':' + @last_result.to_s
#    log_exception(e)
#     'nocontainer'
    rescue EnginesException =>e
      expire_engine_info
      'nocontainer'
      raise e
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
     false
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
     File.exist?(ContainerStateFiles.container_state_dir(self) + '/in_progress')
  end

end