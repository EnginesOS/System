class DockerApi < ErrorsApi

  def destroy_container(cid)
    delete_request({uri: "/containers/#{cid}"})
  end

  require_relative 'docker_api_create_options.rb'


  def create_container(container)
    post(
    {uri: "/containers/create?name=#{container.container_name}",
      params: create_options(container)})
  end
end