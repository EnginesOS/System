module DockerApiContainerStatus
  def inspect_container_by_name(container)

    # container.set_cont_id if container.container_id.to_s == '-1' || container.container_id.nil?
    request = '/containers/' + container.container_name.to_s + '/json'
    return make_request(request, container,true)
  rescue StandardError => e
    log_exception(e)

    #    id = container_id_from_name(container)
    #    return EnginesDockerApiError.new('Missing Container id', :warning) if id == -1
    #    request='/containers/' + id.to_s + '/json'
    #    r =  make_request(request, container)
    #    SystemDebug.debug(SystemDebug.containers,'inspect_container_by_name',container.container_name,r)
    #    return r  if r.is_a?(EnginesError)
    #    r = r[0] if r.is_a?(Array)
    #    return EnginesDockerApiError.new('No Such Container', :warning) if r.key?('RepoTags') #No container by that name and it will return images by that name WTF
    #    return r
    #  rescue StandardError  => e
    #    log_exception(e)
  end

  def inspect_container(container)
    # container.set_cont_id if container.container_id.to_s == '-1' || container.container_id.nil?
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      # return inspect_container_by_name(container)
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/json'
    end
    return make_request(request, container,true)
  rescue StandardError => e
    log_exception(e)
  end

  def ps_container(container)
    id = container.container_id
    id = container_id_from_name(container) if id == -1
    request = '/containers/'  + id + '/top?ps_args=aux'
    r =  make_request(request, container)
    SystemDebug.debug(SystemDebug.containers,'ps_container',container.container_name,r)
    return r
    rescue StandardError => e
      log_exception(e)
  end
  
  def container_name_and_type_from_id(id)
    request = '/containers/' + id.to_s + '/json'
    r =  make_request(request, nil)
    if r.is_a?(FalseClass) # 409 conflict occurs if ask too soon ?
      sleep 0.2 
      return log_error(' 409 ' )      
      r =  make_request(request, nil)
    end
    
    return log_error_mesg('no such engine') if r == true # happens on a destroy
    return r if r.is_a?(EnginesError) 
    return log_error_mesg(' 409 twice for ' + request.to_s) if r == false
    STDERR.puts(' container_name_and_type_from_id GOT ' + r['Config']['Labels'].to_s)
    return log_error_mesg('not a managed engine') unless r.key?('Config')
    return log_error_mesg('not a managed engine') unless r['Config'].key?('Labels')
    return log_error_mesg('not a managed engine') unless r['Config']['Labels'].key?('container_type')
    ret = []
      ret[0] = r['Config']['Labels']['container_name']
      ret[1] = r['Config']['Labels']['container_type']

        ret
rescue StandardError => e
  log_exception(e)
  end
  
  def container_id_from_name(container)
    # request='/containers/json?son?all=false&name=/' + container.container_name
    request='/containers/' + container.container_name + '/json'
    containers_info = make_request(request, container)
    SystemDebug.debug(SystemDebug.containers, 'docker:container_id_from_name  ' ,container.container_name   )
    return -1 unless containers_info.is_a?(Array)
    containers_info.each do |info|
      #  SystemDebug.debug(SystemDebug.containers, 'container_id_from_name  ' ,info['Names'][0]  )
      if info['Names'][0] == '/' + container.container_name
        SystemDebug.debug(SystemDebug.containers, 'MATCHED container_id_from_name  ' ,info['Names'][0],info['Id']    )
        id = info['Id']
        return id
      end
    end
    return -1
  rescue StandardError => e
    log_exception(e)
  end

  def logs_container(container, count)
    #    GET /containers/4fa6e0f0c678/logs?stderr=1&stdout=1&timestamps=1&follow=1&tail=10&since=1428990821 HTTP/1.1
    request = '/containers/' + container.container_id + '/logs?stderr=1&stdout=1&timestamps=1&follow=0&tail=' + count.to_s
   r = make_request(request, nil,false)
    docker_stream_as_result(r)
  end

end