module DockerContainerStatus
  require_relative 'docker_exec.rb'
  def ps_container(container)
    cmdline = 'docker top ' + container.container_name + ' axl'
    result = SystemUtils.execute_command(cmdline)
    return result[:stdout].to_s + ' ' + result[:stderr].to_s
  rescue StandardError => e
    log_exception(e)
    return "Error"
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
    @docker_comms.test_inspect(container)
  end
#  def inspect_container(container)
#    clear_error
#    commandargs = ' docker inspect ' + container.container_name
#    run_docker_cmd(commandargs, container, false)
#  rescue StandardError => e
#    log_exception(e)
#  end
end