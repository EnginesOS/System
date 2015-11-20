module DockerOperations
  require_relative '../docker/docker_api.rb'
  #@returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image(image_name)
    test_docker_api_result(@docker_api.pull_image(image_name))
  end

  def clean_up_dangling_images
    test_docker_api_result(@docker_api.clean_up_dangling_images)
  end
end