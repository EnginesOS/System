module DockerContainerStatus
  require_relative 'docker_exec.rb'
  def ps_container(container)
    @docker_comms.ps_container(container)  
  end

  def logs_container(container, count = 100)
    @docker_comms.logs_container(container, count)
  end

  def inspect_container(container)
    @docker_comms.inspect_container(container)
  end

  def container_id_from_name(container)
    @docker_comms.container_id_from_name(container)
  end

  def inspect_container_by_name(container)
    @docker_comms.inspect_container_by_name(container)
  end

end