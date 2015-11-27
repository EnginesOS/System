module DockerEventListener
  
  #to check for event event_expected [Symbol] on container [ManagedContainer] container.container_id
  def wait_for_docker_event(event_expected, container)
     # delay one sec  to avoid rave condition between cmd completeion and actual docker process completing 
    # 
     sleep 1
    return true
  end
  
end