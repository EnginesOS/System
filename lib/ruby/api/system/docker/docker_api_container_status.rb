module DockerApiContainerStatus

  require_relative 'decoder/docker_decoder.rb'
  def inspect_container_by_name(cn)
    get_request({uri: "/containers/#{cn}/json"})
  end

  def inspect_container(cid)
    get_request({uri: "/containers/#{cid}/json"})
  end

  def ps_container(cid)
    get_request({uri: "/containers/#{cid}/top?ps_args=aux"})
  end

  def container_name_and_type_from_id(cid)
    begin
      r = get_request({uri: "/containers/#{cid}/json"})
    rescue DockerException => e
      raise DockerException.new(warning_hash('Not ready', cid, 409)) if e.status == 409
      raise e
    end

    raise DockerException.new(error_hash('no such engine', cid, 404)) if r == true # happens on a destroy
    raise DockerException.new(error_hash(' 409 twice for ' , request, 409)) unless r.is_a?(Hash)
    raise DockerException.new(error_hash('not a managed engine', r, 404)) unless r.key?(:Config)
    raise DockerException.new(error_hash('not a managed engine', r, 404)) unless r[:Config].key?(:Labels)
    raise DockerException.new(error_hash('not a managed engine', r, 404)) unless r[:Config][:Labels].key?(:container_type)
    [r[:Config][:Labels][:container_name], r[:Config][:Labels][:container_type]]
  end

  def container_id_from_name(cn)
    id = -1
    containers_info = get_request({uri: "/containers/#{cn}/json"})
    if containers_info.is_a?(Array)
      containers_info.each do |info|
        if info[:Names][0] == "/#{cn}"
          id = info[:Id]
          break
        end
      end
    end
    id
  rescue
    -1
  end

  def logs_container(cid, count)
    request = "/containers/#{cid}/logs?stderr=1&stdout=1&timestamps=1&follow=0&tail=#{count}"
    r = get_request({uri: request ,expect_json: false})
    decoder = DockerDecoder.new({chunk: r, result:  {}})
    result = {}
    decoder.decode_from_docker_chunk({chunk: r, result:  result})
    # WHY please response in Comment before before uncommently following lines
    #result[:stdout].gsub!(/[\x80-\xFF]/n,'')
    #result[:stderr].gsub!(/[\x80-\xFF]/n,'')
    result
  end

end