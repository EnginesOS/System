module DockFaceContainerStatus

  require_relative 'decoder/docker_decoder.rb'
  def inspect_container_by_name(cn)
    get({uri: "/containers/#{cn}/json"})
  end

  def inspect_container(cid)
    get({uri: "/containers/#{cid}/json"})
  end

  def ps_container(cid)
    get({uri: "/containers/#{cid}/top?ps_args=aux"})
  end

  def container_name_and_type_from_id(id)
    begin
      r = get({uri: "/containers/#{cid}/json"})
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

  def container_id_from_name(cn)
    STDERR.puts("/containers/#{cn}/json")
    info = get({uri: "/containers/#{cn}/json"})
    STDERR.puts(" Got #{info}")
    info[:Id]
  rescue
    nil
  end

  def logs_container(cid, count)
    request = "/containers/#{cid}/logs?stderr=1&stdout=1&timestamps=1&follow=0&tail=#{count}"
    r = get({uri: request ,expect_json: false})
    decoder = DockerDecoder.new({chunk: r, result:  {}})
    result = {}
    decoder.decode_from_docker_chunk({chunk: r, result:  result})
    result[:stdout].gsub!(/[\x80-\xFF]/n,'')
    result[:stderr].gsub!(/[\x80-\xFF]/n,'')
    result
  end

end