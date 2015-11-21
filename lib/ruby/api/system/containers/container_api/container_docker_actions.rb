module ContainerDockerActions

  def destroy_container(container)
      clear_error
      return true if @docker_api.destroy_container(container)
      return true unless container.has_container?
      return false
    rescue StandardError => e
      container.last_error = 'Failed To Destroy ' + e.to_s
      log_exception(e)
    end
    
  def unpause_container(container)
    clear_error
    test_docker_api_result(@docker_api.unpause_container(container))
  end

  def pause_container(container)
    clear_error
    test_docker_api_result(@docker_api.pause_container(container))
  end

  def image_exist?(container_name)
    @docker_api.image_exist?(container_name)
  end
  def inspect_container(container)
    clear_error
    test_docker_api_result(@docker_api.inspect_container(container))
  end

  def stop_container(container)
    clear_error
    test_docker_api_result(@docker_api.stop_container(container))
  end

  def ps_container(container)
    test_docker_api_result(@docker_api.ps_container(container))
  end

  def logs_container(container, count)
    clear_error
    test_docker_api_result(@docker_api.logs_container(container, count))
  end

  def start_container(container)
    clear_error
    start_dependancies(container) if container.dependant_on.is_a?(Array)
    test_docker_api_result(@docker_api.start_container(container))
  end

  def image_exist?(container_name)
    @docker_api.image_exist?(container_name)
  end
end