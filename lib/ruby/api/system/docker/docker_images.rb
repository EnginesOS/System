module DockerImages

  require_relative 'docker_exec.rb'
  def pull_image(container)
    @docker_comms.pull_image(container)
  end

  def image_exist?(container)
    @docker_comms.image_exist?(container)
  end

  def delete_image(container)
    clear_error
    @docker_comms.delete_container_image(container)
  end

  def clean_up_dangling_images
    images =  @docker_comms.find_images('dangling=true')
    return true if images.is_a?(FalseClass)
    images.each do |image|
      next unless image.is_a?(Hash) && image.key?(:Id)
      @docker_comms.delete_image(image[:Id])
    end
    #    cmd = 'docker rmi $( docker images -f \'dangling=true\' -q) &'
    #    Thread.new { SystemUtils.execute_command(cmd) }
    true # often warning not error
  end

end