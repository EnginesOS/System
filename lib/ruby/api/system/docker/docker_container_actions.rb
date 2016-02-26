module DockerContainerActions
  require_relative 'docker_exec.rb'
  
  def create_container(container)
    clear_error
    commandargs = DockerCmdOptions.container_commandline_args(container)
    commandargs = 'docker run  -d ' + commandargs

    SystemDebug.debug(SystemDebug.docker,'create cont', commandargs)
     docker_cmd_w(commandargs, container)       
  rescue StandardError => e
    container.last_error = ('Failed To Create ')
    log_exception(e)
  end

  def start_container(container)
    clear_error
    commandargs = 'docker start ' + container.container_name
    run_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def stop_container(container)
    clear_error
    commandargs = 'docker stop ' + container.container_name
    run_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def pause_container(container)
    clear_error
    commandargs = 'docker pause ' + container.container_name
    run_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def unpause_container(container)
    clear_error
    commandargs = 'docker unpause ' + container.container_name
    run_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def signal_container_process(pid, signal, container)
    clear_error
    commandargs = 'docker exec ' + container.container_name + ' kill -' + signal + ' ' + pid.to_s
    execute_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def destroy_container(container)
    clear_error
    commandargs = 'docker  rm ' + container.container_name
    unless run_docker_cmd(commandargs, container)
      log_error_mesg(container.last_error, container)
      return false if image_exist?(container.image)
    end
    clean_up_dangling_images
    return true
  rescue StandardError => e
    container.last_error = 'Failed To Destroy ' + e.to_s
    log_exception(e)
  end

end