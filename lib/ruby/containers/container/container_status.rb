module ContainerStatus
  
  def read_state
    self.state = 'nocontainer'
    info = docker_info
#    SystemDebug.debug(SystemDebug.containers, :info)
    if info.is_a?(Hash)
      if info.key?(:State)
        if info[:State][:Running] == true
          if info[:State][:Paused] == true
            self.state = 'paused'
          else
            self.state = 'running'
          end
        elsif info[:State][:Running] == false
          self.state = 'stopped'
        elsif info[:State][:Status] == 'exited'
          self.state = 'stopped'
        end
   #     SystemDebug.debug(SystemDebug.containers, :no_matched_info, info)
      end
    end
    SystemDebug.debug(SystemDebug.containers, 'in State', state)
    self.state
  end

  def is_paused?
    if read_state == 'paused'
      true
    else
      false
    end
  end

  def is_active?
    self.state = read_state
    case self.state
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
   # STDERR.puts( ' Docker info is a ' + info.class.name)
    if info.is_a?(FalseClass) ||info.nil? || info[:State][:StartedAt].nil?
      0
    else
      begin        
     Time.now.to_i - Time.parse(info[:State][:StartedAt]).to_i
      rescue StandardError => e
        STDERR.puts( ' ex ' + e.to_s)
        0  
     end        
    end
  end
  
  def to_s
    "#{container_name}:#{ctype}"
  end
  
end