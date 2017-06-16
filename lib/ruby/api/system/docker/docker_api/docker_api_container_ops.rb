module DockerApiContainerOps
  def container_exist?(container)

    if container.container_id.to_s == '-1' || container.container_id.to_s == ''
      r = @docker_comms.inspect_container_by_name(container)
    else
      request = '/containers/' + container.container_id.to_s + '/json'
      r = get_request(request)
    end
    if r.is_a?(Hash)
      true
    else
      false
    end
  rescue
    false
  end

  def destroy_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s
      delete_request(request)
    end
  end

  require_relative 'docker_api_create_options.rb'
  include DockerApiCreateOptions

  def create_container(container)
    request_params = create_options(container)
    request = '/containers/create?name=' + container.container_name
    # STDERR.puts('/containers/create?name=' +  container.container_name)
    # STDERR.puts('opts' + request_params.to_s)
    post_request(request, request_params)
  end
end