module ContainerStatus
  def read_state
    info = docker_info
    state = 'nocontainer'
   # p :read_state
 #  p info.class.name
    return state unless info.is_a?(Hash)
  #   p :STATE
   # p info['State']['Running']
    unless info['State'].nil?
      if info['State']['Running']
        state = 'running'
        if  info['State']['Paused']
          return 'paused'
        end
      elsif info['State']['Running'] == false
        return 'stopped'
      else
        p :info
        p info['State'].to_s
        return 'nocontainer'
      end
    end
    p :no_state_info
    p info.class.name
    p info.to_s
    return 'nocontainer'
  rescue StandardError => e
    log_exception(e)
  end

  def is_paused?
    state = read_state
    return true if state == 'paused'
    return false
  end

  def is_active?
    state = read_state
    case state
    when 'running'
      return true
    when 'paused'
      return true
    else
      return false
    end
  end

  def is_running?
    state = read_state
    return true if state == 'running'
    return false
  end

  def has_container?
    # return false if has_image? == false NO Cached
    return false if read_state == 'nocontainer'
    return true
  end

end