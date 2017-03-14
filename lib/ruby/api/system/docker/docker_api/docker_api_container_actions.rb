module DockerApiContainerActions
  def start_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/start'
    end
     post_request(request)
  rescue StandardError => e
    log_exception(e)
  end

  def pause_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/pause'
    end
     post_request(request)
  rescue StandardError => e
    log_exception(e)
  end

  def unpause_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/unpause'
    end
     post_request(request)
  rescue StandardError => e
    log_exception(e)

  end

  def stop_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      stop_timeout = 25
      stop_timeout = container.stop_timeout unless container.stop_timeout.nil?
      request = '/containers/' + container.container_id.to_s + '/stop?t=' + stop_timeout.to_s
    end
     post_request(request)
  rescue StandardError => e
    log_exception(e)
  end
end