module ContainerApiDockerActions
  def destroy_container(container)
    clear_error
    docker_api.destroy_container(container.container_id)
  end

  def unpause_container(cid)
    clear_error
    docker_api.unpause_container(cid)
  end

  def pause_container(cid)
    clear_error
    docker_api.pause_container(cid)
  end

  def image_exist?(iname)
    docker_api.image_exist?(iname)
  rescue
    false
  end

  def inspect_container_by_name(cn)
    docker_api.inspect_container_by_name(cn)
  end

  def inspect_container(cid)
    clear_error
     docker_api.inspect_container(cid)
  end

  def stop_container(cid, to)
    clear_error
    docker_api.stop_container(cid, to)
    #rotate_log(container)
    true
  end

  def rotate_log(cid)
    system_api.rotate_container_log(cid)
  end

  def ps_container(cid)
    docker_api.ps_container(cid)
  end

  def logs_container(cid, count)
    clear_error
    docker_api.logs_container(cid, count)
  end

  def start_container(container)
    clear_error
    passed_checks = pre_start_checks(container)
    raise EnginesException.new(warning_hash('Failed pre start checks:' + passed_checks.to_s , container.container_name)) unless passed_checks.is_a?(TrueClass)
    start_dependancies(container) if container.dependant_on.is_a?(Array)
    wait_for_dependacies_startup(container)
    docker_api.start_container(container.container_id)
  end

  def image_exist?(iname)
    docker_api.image_exist?(iname)
  rescue DockerExecption
    false
  end
end
