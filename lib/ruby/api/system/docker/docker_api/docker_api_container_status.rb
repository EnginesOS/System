module DockerApiContainerStatus
  def inspect_container_by_name(container)

    # container.set_cont_id if container.container_id.to_s == '-1' || container.container_id.nil?
    request = '/containers/' + container.container_name.to_s + '/json'
    return get_request(request, true)

  end

  def inspect_container(container)
    # container.set_cont_id if container.container_id.to_s == '-1' || container.container_id.nil?
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      # return inspect_container_by_name(container)
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/json'
    end
    get_request(request, true)
  end

  def ps_container(container)
    id = container.container_id
    id = container_id_from_name(container) if id == -1
    request = '/containers/'  + id + '/top?ps_args=aux'
    get_request(request)
  end

  def container_name_and_type_from_id(id)
    request = '/containers/' + id.to_s + '/json'
    r = ''
    begin
      r =  get_request(request)
    rescue DockerException => e
      if e.status == 409
        sleep 0.2
        r =  get_request(request)
      else raise e
      end
    end

    raise DockerException.new(error_hash('no such engine', id)) if r == true # happens on a destroy

    raise DockerException.new(error_hash(' 409 twice for '  , request)) unless r.is_a?(Hash)

    raise DockerException.new(error_hash('not a managed engine', r)) unless r.key?(:Config)
    raise DockerException.new(error_hash('not a managed engine', r)) unless r[:Config].key?(:Labels)
    raise DockerException.new(error_hash('not a managed engine', r)) unless r[:Config][:Labels].key?(:container_type)

    [r[:Config][:Labels][:container_name], r[:Config][:Labels][:container_type]]

  end

  def container_id_from_name(container)
    # request='/containers/json?son?all=false&name=/' + container.container_name
    request='/containers/' + container.container_name + '/json'
    containers_info = get_request(request)
    SystemDebug.debug(SystemDebug.containers, 'docker:container_id_from_name  ' ,container.container_name   )
    return -1 unless containers_info.is_a?(Array)
    containers_info.each do |info|
      #  SystemDebug.debug(SystemDebug.containers, 'container_id_from_name  ' ,info['Names'][0]  )
      if info[:Names][0] == '/' + container.container_name
        SystemDebug.debug(SystemDebug.containers, 'MATCHED container_id_from_name  ' ,info[:Names][0],info[:Id]    )
        id = info[:Id]
        return id
      end
    end
    -1
rescue 
   -1
  end

  def logs_container(container, count)
    raise DockerException.new(docker_error_hash(' No Container ID ', container.container_name)) if container.container_id == -1
    #    GET /containers/4fa6e0f0c678/logs?stderr=1&stdout=1&timestamps=1&follow=1&tail=10&since=1428990821 HTTP/1.1
    request = '/containers/' + container.container_id .to_s + '/logs?stderr=1&stdout=1&timestamps=1&follow=0&tail=' + count.to_s
    r = get_request(request, false)
    result = {}
    DockerUtils.docker_stream_as_result(r , result)
    result
  end

end