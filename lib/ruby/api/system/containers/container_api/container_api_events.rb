module ContainerApiEvents
  
  def wait_for(state)
    return if read_state == state
    
    case state
    when 'stopped'
      @event_mutex = Mutex.new
      @event_mutex.lock
    @system_api.add_event_listener([self,'state_reached'.to_sym],1 | 512 | 256 , @container_id)
    @event_mutex.lock
    @event_mutex.unlock
    end
  end

  def state_reached(event_hash)
    @event_mutex.unlock
  end
    
end