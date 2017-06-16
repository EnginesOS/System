module ContainerStatus
  def read_state
    state = 'nocontainer'
    info = docker_info
    SystemDebug.debug(SystemDebug.containers, :info)
    unless info.is_a?(Hash)
      if info.key?(:State)
        if info[:State][:Running]
          if  info[:State][:Paused]
            state = 'paused'
          else
            state = 'running'
          end
        elsif info[:State][:Running] == false
          state = 'stopped'
        elsif info[:State][:Status] == 'exited'
          state = 'stopped'
        else
          SystemDebug.debug(SystemDebug.containers, :no_matched_info, info)
        end
      end
    end
     SystemDebug.debug(SystemDebug.containers,  'in State', state.to_s)
    state
  end

  def is_paused?
    if read_state == 'paused'
      true
    else
      false
    end
  end

  def is_active?
    state = read_state
    case state
    when 'running','paused'
      true
    else
      false
    end
  end

  def is_stopped?
    if read_state == 'stopped'
      true
    else
      false
    end
  end

  def is_running?
    if read_state == 'running'
      r = true
    else
      r = false
    end
    r
  end

  def has_container?
    # return false if has_image? == false NO Cached
    if read_state == 'nocontainer'
      false
    else
      true
    end
  end

  def to_s
    @container_name + ':' + @ctype
  end
end