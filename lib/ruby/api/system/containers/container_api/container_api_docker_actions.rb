module ContainerApiDockerActions
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

 def inspect_container_by_name(container) 
   @docker_api.inspect_container_by_name(container) 
   # docker_info
#    SystemDebug.debug(SystemDebug.containers, 'DockerInfoCollector:Meth read_container_id ' ,info)
#     if info.is_a?(Array)
#       @container_id = info[0]['Id']
#     save_container
#     else
#     SystemDebug.debug(SystemDebug.containers, ' DockerInfoCollector:Meth ' ,info)
#     @container_id  = -1   
#   end   
 end
 
  def inspect_container(container)
    clear_error
    return  test_docker_api_result(@docker_api.inspect_container_by_name(container)) if container.container_id == -1
    test_docker_api_result(@docker_api.inspect_container(container))
   # @docker_api.test_inspect_container(container)
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
    return log_error_mesg("insuficient free memory to start",container) unless have_enough_ram?(container)
    start_dependancies(container) if container.dependant_on.is_a?(Array)
    test_docker_api_result(@docker_api.start_container(container))
  end

  def image_exist?(container_name)
    @docker_api.image_exist?(container_name)
  end
end