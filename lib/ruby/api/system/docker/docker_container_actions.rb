module DockerContainerActions
  def create_container(container, create_only = false)
    r = @docker_comms.create_container(container)
  end

  def start_container(container)
    @docker_comms.start_container(container)
  end

  def stop_container(container)
    @docker_comms.stop_container(container)
  end

  def pause_container(container)
    @docker_comms.pause_container(container)
  end

  def unpause_container(container)
    @docker_comms.unpause_container(container)
  end

  def signal_container_process(pid, signal, container)
    cmds =['kill','-' + signal, pid]
    @docker_comms.docker_exec({:container => container, :command_line=>cmds, :log_error=>false})
  end

  def destroy_container(container)
    @docker_comms.destroy_container(container)
    unless @docker_comms.container_exist?(container)
      clean_up_dangling_images
      true
    else
      false
    end
  end

end