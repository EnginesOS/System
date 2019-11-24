module ContainerDockDockerActions
  def destroy_container(container)
    clear_error
    dock_face.destroy_container(container.id)
  end

  def unpause_container(cid)
    clear_error
    dock_face.unpause_container(cid)
  end

  def pause_container(cid)
    clear_error
    dock_face.pause_container(cid)
  end

  def image_exist?(iname)
    dock_face.image_exist?(iname)
  rescue
    false
  end

  def inspect_container_by_name(cn)
    dock_face.inspect_container_by_name(cn)
  end

  def inspect_container(cid)
    clear_error
     dock_face.inspect_container(cid)
  end

  def stop_container(cid, to=30)
    clear_error
    dock_face.stop_container(cid, to)
    #rotate_log(container)
    true
  end

  def rotate_log(cid)
    system_api.rotate_container_log(cid)
  end

  def ps_container(cid)
    dock_face.ps_container(cid)
  end

  def logs_container(cid, count)
    clear_error
    dock_face.logs_container(cid, count)
  end

  def start_container(container)
    clear_error
  #  raise EnginesException.new(warning_hash('Failed pre start checks:' + passed_checks.to_s , container.container_name)) unless passed_checks.is_a?(TrueClass)
    start_dependancies(container) if container.dependant_on.is_a?(Array)
    wait_for_dependacies_startup(container)
    dock_face.start_container(container.id)
  end

  def image_exist?(iname)
    dock_face.image_exist?(iname)
  rescue DockerExecption
    false
  end
end
