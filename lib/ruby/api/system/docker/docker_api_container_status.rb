module DockerApiContainerStatus
  def inspect_container_by_name(container)
    get_request({uri: '/containers/' + container.container_name.to_s + '/json'})
  end

  def inspect_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      get_request({uri: '/containers/' + container.container_id.to_s + '/json'})
    end
  end

  def ps_container(container)
    id = container.container_id
    id = container_id_from_name(container) if id == -1
    get_request({uri: '/containers/'  + id + '/top?ps_args=aux'})
  end

  def container_name_and_type_from_id(id)
    begin
      r = get_request({uri: '/containers/' + id.to_s + '/json'})
    rescue DockerException => e
      raise DockerException.new(warning_hash('Not ready', id, 409))  if e.status == 409
      raise e
    end

    raise DockerException.new(error_hash('no such engine', id, 404)) if r == true # happens on a destroy
    raise DockerException.new(error_hash(' 409 twice for ' , request, 409)) unless r.is_a?(Hash)
    raise DockerException.new(error_hash('not a managed engine', r, 404)) unless r.key?(:Config)
    raise DockerException.new(error_hash('not a managed engine', r, 404)) unless r[:Config].key?(:Labels)
    raise DockerException.new(error_hash('not a managed engine', r, 404)) unless r[:Config][:Labels].key?(:container_type)
    [r[:Config][:Labels][:container_name], r[:Config][:Labels][:container_type]]
  end

  def container_id_from_name(container)
    id = -1
    containers_info = get_request({uri: '/containers/' + container.container_name + '/json'})
    if containers_info.is_a?(Array)
      containers_info.each do |info|
        if info[:Names][0] == '/' + container.container_name
          id = info[:Id]
          break
        end
      end
    end
    id
  rescue
    -1
  end

  def logs_container(container, count)
    raise DockerException.new(docker_error_hash(' No Container ID ', container.container_name)) if container.container_id == -1   
    request = '/containers/' + container.container_id .to_s + '/logs?stderr=1&stdout=1&timestamps=1&follow=0&tail=' + count.to_s
    r = get_request({uri: request ,expect_json: false})
    r = DockerUtils.decode_from_docker_chunk({chunk: r, result:  {}})
    r[:stdout].gsub!(/[\x80-\xFF]/n,'')
    r[:stderr].gsub!(/[\x80-\xFF]/n,'')
    r
  end

end