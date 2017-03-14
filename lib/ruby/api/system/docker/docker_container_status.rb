module DockerContainerStatus
  require_relative 'docker_exec.rb'
  def ps_container(container)
    @docker_comms.ps_container(container)
  rescue StandardError => e
    log_exception(e)

  end

  def logs_container(container, count = 100)
    @docker_comms.logs_container(container, count)
#    cmdline = 'docker logs --tail=' + count.to_s + ' ' + container.container_name
#    result = SystemUtils.execute_command(cmdline)
#    return result[:stderr].to_s + ' ' + result[:stdout].to_s
  rescue StandardError => e
    log_exception(e)
   
  end

  def inspect_container(container)
    @docker_comms.inspect_container(container)
  end

  def container_id_from_name(container)
    @docker_comms.container_id_from_name(container)
  end

  def inspect_container_by_name(container)
    @docker_comms.inspect_container_by_name(container)

  rescue StandardError => e
    return log_error_mesg('No such Container ', container.container_name)          
  ## log_exception(e,'No such Container' + result[:stdout].to_s)
  end

end