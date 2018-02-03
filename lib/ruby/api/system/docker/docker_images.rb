module DockerImages
  def pull_image(container)
    @docker_comms.pull_image(container)
  end

  def image_exist?(container)
    @docker_comms.image_exist?(container)
  end

  def delete_image(container)
    @docker_comms.delete_container_image(container)
  end

  def clean_up_dangling_images
    @docker_comms.clean_up_dangling_images
   
    true # often warning not error
  end

end