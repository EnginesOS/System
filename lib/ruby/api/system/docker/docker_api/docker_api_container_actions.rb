module DockerApiContainerActions
  def start_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/start'
      post_request(request)
    end
  end

  def pause_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/pause'
      post_request(request)
    end
  end

  def unpause_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/unpause'
      post_request(request)
    end
  end

  def stop_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      stop_timeout = 25
      stop_timeout = container.stop_timeout unless container.stop_timeout.nil?
      request = '/containers/' + container.container_id.to_s + '/stop?t=' + stop_timeout.to_s
      post_request(request)
    end
  end
end