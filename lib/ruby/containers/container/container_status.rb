module ContainerStatus
  def read_state
    state = 'nocontainer'
    info = docker_info
    SystemDebug.debug(SystemDebug.containers, :info)
    if info.is_a?(Hash)
      if info.key?(:State)
        if info[:State][:Running] == true
          if info[:State][:Paused] == true
            state = 'paused'
          else
            state = 'running'
          end
        elsif info[:State][:Running] == false
          state = 'stopped'
        elsif info[:State][:Status] == 'exited'
          state = 'stopped'
        end
      else
        SystemDebug.debug(SystemDebug.containers, :no_matched_info, info)
      end
    end
    SystemDebug.debug(SystemDebug.containers, 'in State', state.to_s)
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
      true
    else
      false
    end
  end

  def has_container?
    # return false if has_image? == false NO Cached
    if read_state == 'nocontainer'
      false
    else
      true
    end
  end

  def uptime
    info = docker_info
    STDERR.puts( ' Docker info is a ' + info.class.name)
    STDERR.puts( ' Docker info is ' + info.to_s)
    
    if info.is_a?(FalseClass) ||info.nil? || info[:State][:StartedAt].nil?
      0
    else
      begin
        STDERR.puts( ' Now ' + DateTime.now.to_i.to_s)
        STDERR.puts( ' Data parse ' + DateTime.parse(info[:State][:StartedAt]).to_s)
     DateTime.now.to_i - DateTime.parse(info[:State][:StartedAt]).to_i
      rescue StandardError => e
        STDERR.puts( ' ex ' + e.to_s)
        0  
     end        
    end
  end
  
  def to_s
    @container_name + ':' + @ctype
  end
end