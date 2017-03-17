module DockerContainerActions
  require_relative 'docker_exec.rb'
  
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
    clear_error
    cmds =['kill','-' + signal, pid]
    @docker_comms.docker_exec({:container => container, :command_line=>cmds, :log_error=>false})
 
  end

  def destroy_container(container)
    @docker_comms.destroy_container(container)
      return false if @docker_comms.container_exist?(container)
    #end
    clean_up_dangling_images
    return true

  end

end