module DockerApiContainerOps
  def container_exist?(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s == ''
      r = @docker_comms.inspect_container_by_name(container)
      return true if r.is_a?(Hash)
      return false
    else
      request = '/containers/' + container.container_id.to_s + '/json'
    end
    r = get_request(request)
    return true if r.is_a?(Hash)
    false
  rescue
    false
  end

  def destroy_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s
    end
    delete_request(request)
  end

  require_relative 'docker_api_create_options.rb'
  include DockerApiCreateOptions

  def create_container(container)
    request_params = create_options(container)
    request = '/containers/create?name=' + container.container_name
    post_request(request, request_params)
  end
end