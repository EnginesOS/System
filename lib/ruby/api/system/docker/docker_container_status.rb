module DockerContainerStatus
  require_relative 'docker_exec.rb'
  def ps_container(container)
    @docker_comms.ps_container
#    cmdline = 'docker top ' + container.container_name + ' axl'
#    result = SystemUtils.execute_command(cmdline)
#    SystemDebug.debug(SystemDebug.containers, 'PS  container ',container.container_name  ,result[:stdout],result)
#    return result[:stdout].to_s + ' ' + result[:stderr].to_s
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
    @docker_comms.inspect_container(container)
  end
  def container_id_from_name(container)
    @docker_comms.container_id_from_name(container)
  end
  def inspect_container_by_name(container)
    cmdline = 'docker inspect ' + container.container_name
    result = SystemUtils.execute_command(cmdline)
    res = JSON.parse(result[:stdout], :create_additions => true)
      return res #SystemUtils.deal_with_jason(res)
    rescue StandardError => e
        log_exception(e,container.container_)
        return 'error inspect_container_by_name  ' + e.to_s
  end
 
end