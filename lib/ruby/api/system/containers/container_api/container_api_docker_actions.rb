module ContainerApiDockerActions
  def destroy_container(container)
    clear_error
    @docker_api.destroy_container(container)
    ! container.has_container?
  end

  def unpause_container(container)
    clear_error
    @docker_api.unpause_container(container)
  end

  def pause_container(container)
    clear_error
    @docker_api.pause_container(container)
  end

  def image_exist?(container_name)
    @docker_api.image_exist?(container_name)
  rescue
    false
  end

  def inspect_container_by_name(container)
    @docker_api.inspect_container_by_name(container)
  end

  def inspect_container(container)
    clear_error
    return @docker_api.inspect_container_by_name(container) if container.container_id == -1
    @docker_api.inspect_container(container)
  end

  def stop_container(container)
    clear_error
    @docker_api.stop_container(container)
    rotate_log(container)
  end

  def rotate_log(container)
    @system_api.rotate_container_log(container.container_id)
  end

  def ps_container(container)
    @docker_api.ps_container(container)
  end

  def logs_container(container, count)
    clear_error
    @docker_api.logs_container(container, count)
  end

  def start_container(container)
    clear_error
    enough_ram = have_enough_ram?(container)
    raise EnginesException.new(error_hash("Insuficient free memory to start", container.to_s)) unless enough_ram
    start_dependancies(container) if container.dependant_on.is_a?(Array)
    @docker_api.start_container(container)
  end

  def image_exist?(container_name)
    @docker_api.image_exist?(container_name)
  rescue DockerExecption
    false
  end
end