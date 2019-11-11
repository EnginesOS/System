module ContainerDockEvents

  def wait_for(container, what, timeout)
    event_handler.wait_for(container, what, timeout)
  end

end
