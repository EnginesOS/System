module DockerOperations
  # require '/opt/engines/lib/ruby/api/system/docker/dock_face.rb'
  # @returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image(image_name)
    dock_face.pull_image(image_name)
  end

  def clean_up_dangling_images
    dock_face.clean_up_dangling_images
  end

  def exec_in_container(params)  
    dock_face.docker_exec(params)
  end

  def container_name_and_type_from_id(id)
    dock_face.container_name_and_type_from_id(id)
  end
end
