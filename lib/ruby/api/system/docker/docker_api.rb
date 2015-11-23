class DockerApi < ErrorsApi
  require_relative 'docker_cmd_options'
  require_relative 'docker_event_listener.rb'
  include DockerEventListener 
  
  def create_container(container)
    clear_error
    commandargs = DockerCmdOptions.container_commandline_args(container)
    commandargs = 'docker run  -d ' + commandargs
    SystemUtils.debug_output('create cont', commandargs)
    return wait_for_docker_event(:create, container) if run_docker_cmd(commandargs, container)
    return false
  rescue StandardError => e
    container.last_error = ('Failed To Create ')
    log_exception(e)
  end

  def start_container(container)
    clear_error
    commandargs = 'docker start ' + container.container_name
    return wait_for_docker_event(:start, container) if run_docker_cmd(commandargs, container)
    return false
  rescue StandardError => e
    log_exception(e)
  end

  def stop_container(container)
    clear_error
    commandargs = 'docker stop ' + container.container_name
    return wait_for_docker_event(:stop, container) if run_docker_cmd(commandargs, container)
    return false
  rescue StandardError => e
    log_exception(e)
  end

  def pause_container(container)
    clear_error
    commandargs = 'docker pause ' + container.container_name
    return wait_for_docker_event(:pause, container) if run_docker_cmd(commandargs, container)
    return false
  rescue StandardError => e
    log_exception(e)
  end

  def pull_image(image_name)
    cmd = 'docker pull ' + image_name
    SystemUtils.debug_output('Pull Image', cmd)
    result = SystemUtils.execute_command(cmd)
    @last_error = result[:stdout]
    if result[:result] != 0
      return true if result[:stdout].include?('Status: Image is up to date for ' + image_name) == true
      @last_error += ':' + result[:stderr].to_s
      return false
    end
    return true if result[:stdout].include?('Status: Image is up to date for ' + image_name) == true
    @last_error += ':' + result[:stderr].to_s
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def image_exist?(imagename)
    image_name = imagename.gsub(/:.*$/, '')
    cmd = 'docker images -q ' + image_name
    result = SystemUtils.execute_command(cmd)
    @last_error = result[:stderr].to_s
    return false if result[:result] != 0
    return true if result[:stdout].length > 4
    return false # Otherwise returnsresult[:stdout]
  rescue StandardError => e
    log_exception(e)
  end

  def unpause_container(container)
    clear_error
    commandargs = 'docker unpause ' + container.container_name
    return wait_for_docker_event(:unpause, container) if run_docker_cmd(commandargs, container)
    return false
  rescue StandardError => e
    log_exception(e)
  end

  def ps_container(container)
    cmdline = 'docker top ' + container.container_name + ' axl'
    result = SystemUtils.execute_command(cmdline)
    return result[:stdout].to_s + ' ' + result[:stderr].to_s
  rescue StandardError => e
    log_exception(e)
    return "Error"
  end

  def execute_docker_cmd(cmdline, container)
    clear_error
    if cmdline.include?('docker exec')
      docker_exec = 'docker exec -u ' + container.cont_userid + ' '
      cmdline.gsub!(/docker exec/, docker_exec)
    end
    run_docker_cmd(cmdline, container)
  end

  def run_docker_cmd(cmdline, container)

    result = SystemUtils.execute_command(cmdline)
    container.last_result = result[:stdout]
    #    if container.last_result.start_with?('[') && !container.last_result.end_with?(']')  # || container.last_result.end_with?(']') )
    #      container.last_result += ']'
    #    end
    container.last_error = result[:stderr]
    if result[:result] == 0
      container.last_error = result[:result].to_s + ':' + result[:stderr].to_s

      return true
    else
      container.last_error = result[:result].to_s + ':' + result[:stderr].to_s
      log_error_mesg('execute_docker_cmd ' + cmdline + ' on ' + container.container_name, result)
      return false
    end
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

  def logs_container(container, count)
    clear_error
    cmdline = 'docker logs --tail=' + count.to_s + ' ' + container.container_name
    result = SystemUtils.execute_command(cmdline)
    return result[:stderr].to_s + ' ' + result[:stdout].to_s
  rescue StandardError => e
    log_exception(e)
    return 'error retriving logs ' + e.to_s
  end

  def inspect_container(container)
    clear_error
    commandargs = ' docker inspect ' + container.container_name
    run_docker_cmd(commandargs, container)
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
    wait_for_docker_event(:rm, container) 
    clean_up_dangling_images
    return true
  rescue StandardError => e
    container.last_error = 'Failed To Destroy ' + e.to_s
    log_exception(e)
  end

  def delete_image(container)
    clear_error
    commandargs = 'docker rmi -f ' + container.image
    ret_val =  run_docker_cmd(commandargs, container)
    wait_for_docker_event(:stop, container) if ret_val == true
    clean_up_dangling_images if ret_val == true
    return ret_val
  rescue StandardError => e
    container.last_error = ('Failed To Delete ' + e.to_s)
    log_exception(e)
  end

  #  def docker_exec(container, command, args)
  #    run_args = 'docker exec ' + container.container_name + ' ' + command + ' ' + args
  #    execute_docker_cmd(run_args, container)
  #  end

  def clean_up_dangling_images
    cmd = 'docker rmi $( docker images -f \'dangling=true\' -q) &'
    Thread.new { SystemUtils.execute_command(cmd) }
    return true # often warning not error
  end

end
