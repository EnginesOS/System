module DockFaceContainerOps

  def destroy_container(cid)
    delete_request({uri: "/containers/#{cid}"})
  end

  require_relative 'dock_face_create_options.rb'
  #include DockFaceCreateOptions

  def create_container(c)    
    post(
    {uri: "/containers/create?name=#{c.container_name}",
      params: DockFaceCreateOptions.create_options(c)})
  end
end