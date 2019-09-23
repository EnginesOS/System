module DockerApiContainerActions
  def start_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      post_request({uri: '/containers/' + container.container_id.to_s + '/start'})
    end
  end

  def pause_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      post_request({uri: '/containers/' + container.container_id.to_s + '/pause'})
    end
  end

  def unpause_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      post_request({uri: '/containers/' + container.container_id.to_s + '/unpause'})
    end
  end

  def stop_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      stop_timeout = 25
      stop_timeout = container.stop_timeout unless container.stop_timeout.nil?
      post_request({uri: '/containers/' + container.container_id.to_s + '/stop?t=' + stop_timeout.to_s})
    end
  end
end