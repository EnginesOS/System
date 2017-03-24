module DockerOperations
  require '/opt/engines/lib/ruby/api/system/docker/docker_api.rb'

  # @returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image(image_name)
    @docker_api.pull_image(image_name)
  end

  def clean_up_dangling_images
    @docker_api.clean_up_dangling_images
  end

  def exec_in_container( params ) #container, commandline, log_error = false, data = nil)
    @docker_api.docker_exec(params) #params[:container], params[:command_line], params[:log_error], params[:data])
  end

  def container_name_and_type_from_id(id)
    @docker_api.container_name_and_type_from_id(id)
  end
end