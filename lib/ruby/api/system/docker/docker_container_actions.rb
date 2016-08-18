module DockerContainerActions
  require_relative 'docker_exec.rb'
  
  def create_container(container, create_only = false)
   r = @docker_comms.create_container(container)
    STDERR.puts(' CREATED ' + r.to_s)
   return r if create_only == true || r.is_a?(EnginesError) 
   STDERR.puts(' CREATED AND NOW STARTING ')
    @docker_comms.start_container(container)
#
  rescue StandardError => e
    container.last_error = ('Failed To Create ')
    log_exception(e)
  end

  def start_container(container)

    @docker_comms.start_container(container)
  rescue StandardError => e
    log_exception(e)
  end

  def stop_container(container)
    @docker_comms.stop_container(container)
  rescue StandardError => e
    log_exception(e)
  end

  def pause_container(container)
    @docker_comms.pause_container(container)
  rescue StandardError => e
    log_exception(e)
  end

  def unpause_container(container)
    @docker_comms.unpause_container(container)
  rescue StandardError => e
    log_exception(e)
  end

  def signal_container_process(pid, signal, container)
    clear_error
 #   commandargs = 'docker exec ' + container.container_name + ' kill -' + signal + ' ' + pid.to_s
    cmds =['kill','-' + signal, pid]
    #execute_docker_cmd(commandargs, container)
    @docker_comms.docker_exec({:container => container, :command_line=>cmds, :log_error=>false})
  rescue StandardError => e
    log_exception(e)
  end

  def destroy_container(container)

    @docker_comms.destroy_container(container)
      return false if @docker_comms.container_exist?(container)
    #end
    clean_up_dangling_images
    return true
  rescue StandardError => e
    container.last_error = 'Failed To Destroy ' + e.to_s
    log_exception(e)
  end

end