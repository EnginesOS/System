module ContainerStatus
  
  def read_state
    info = docker_info
    state = 'nocontainer'
     p info[0]['State'].to_s
            if info[0]['State']
              if info[0]['State']['Running']
                state = 'running'
                if info[0]['State']['Paused']
                  state= 'paused'
                end
              elsif info[0]['State']['Running'] == false
                state = 'stopped'
              else
                state = 'nocontainer'
              end
            end           
           return state
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