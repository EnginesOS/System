module ContainerStatus
  def read_state
    info = docker_info
    SystemDebug.debug(SystemDebug.containers, :info, info)
    return 'nocontainer' unless info.is_a?(Hash)

    if info.key?(:State)
      if info[:State][:Running]
        if  info[:State][:Paused]
          return 'paused'
        else
          return 'running'
        end
      elsif info[:State][:Running] == false
        return 'stopped'
      elsif info[:State][:Status] == 'exited'
        return 'stopped'
      else
        SystemDebug.debug(SystemDebug.containers, :info, info)
        return 'nocontainer'
      end
    end
    # SystemDebug.debug(SystemDebug.containers,  'no_matching state_info', info.class.name, info)
    'nocontainer'
  end

  def is_paused?
    return true if read_state == 'paused'
    false
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

  def is_stopped?
    return true if read_state == 'stopped'
    false
  end

  def is_running?
    return true if read_state == 'running'
    false
  end

  def has_container?
    # return false if has_image? == false NO Cached
    return false if read_state == 'nocontainer'
    true
  end

end