module ContainerApiEvents

  def wait_for(container, what, timeout)
    @system_api.wait_for(container, what, timeout)
  end
  
end