module DockFaceContainerOps

  def destroy_container(cid)
    delete_request({uri: "/containers/#{cid}"})
  end

  require_relative 'dock_face_create_options.rb'
  include DockFaceCreateOptions

  def create_container(container)
    post(
    {uri: "/containers/create?name=#{container.container_name}",
      params: create_options(container)})
  end
end