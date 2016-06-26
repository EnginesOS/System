module DockerApiContainerOps
  def container_exist?(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      # return inspect_container_by_name(container)
      r = @docker_comms.inspect_container_by_name(container)
      return true if r.is_a?(Hash)
      return false
    else
      request = '/containers/' + container.container_id.to_s + '/json'
    end
    r = make_request(request, container)
    STDERR.puts('container_exists ' + r.to_s)
    return true if r.is_a?(Hash)
    return false
  rescue StandardError => e
    return false
  end

  def destroy_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s
    end
    return make_del_request(request, container)
  rescue StandardError => e
    log_exception(e)
  end

  require_relative 'docker_api_create_options.rb'
  include DockerApiCreateOptions

  def create_container(container)
    request_params = create_options(container)
    request = '/containers/create?name=' + container.container_name
    r = make_post_request(request, container, request_params)
    STDERR.puts('DOCKER EXEC ' + r.to_s + ': for :' + container.container_name + ': with :' + request_params.to_s)

  end

 

end