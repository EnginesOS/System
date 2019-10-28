module DockerApiContainerOps
  #  def container_exist?(container)
  #    if container.container_id.to_s == '-1' || container.container_id.to_s == ''
  #      r = @docker_comms.inspect_container_by_name(container)
  #    else
  #      r = get_request({uri: "/containers/#{container.container_id}/json"})
  #    end
  #    if r.is_a?(Hash)
  #      true
  #    else
  #      false
  #    end
  #  rescue
  #    false
  #  end
  def destroy_container(cid)
    delete_request({uri: "/containers/#{cid}"})
  end

  require_relative 'docker_api_create_options.rb'
  include DockerApiCreateOptions

  def create_container(container)
    post(
    {uri: "/containers/create?name=#{container.container_name}",
      params: create_options(container)})
  end
end