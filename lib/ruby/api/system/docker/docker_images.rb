module DockerImages

  require_relative 'docker_exec.rb'
  def pull_image(container)
    @docker_comms.pull_image(container)
#    cmd = 'docker pull ' + image_name
#    SystemDebug.debug(SystemDebug.docker,'Pull Image', cmd)
#    result = SystemUtils.execute_command(cmd)
#    STDERR.puts(' docker pull IMAGE ' + cmd + ' ' + result.to_s)
#    @last_error = result[:stdout]
#    if result[:result] != 0
#      return true if result[:stdout].include?('Status: Image is up to date for ' + image_name) == true
#      @last_error += ':' + result[:stderr].to_s
#      return log_error_mesg('Failed to pull image ' + result[:stderr].to_s)
#    end
#    return true if result[:stdout].include?('Status: Image is up to date for ' + image_name) == true
#    @last_error += ':' + result[:stderr].to_s
#    return true
  rescue StandardError => e
    log_exception(e)
  end

  def image_exist?(container)
    @docker_comms.image_exist?(container)
#    image_name = imagename.gsub(/:.*$/, '')
#    cmd = 'docker images -q ' + image_name
#    result = SystemUtils.execute_command(cmd)
#    #    @last_error = result[:stderr].to_s
#    return false if result[:result] != 0
#    return true if result[:stdout].length > 4
#    return false # Otherwise returnsresult[:stdout]
  rescue StandardError => e
    log_exception(e)
  end

  def delete_image(container)
    clear_error
    @docker_comms.delete_container_image(container)
#    commandargs = 'docker rmi -f ' + container.image
#    ret_val =  run_docker_cmd(commandargs, container)
#    clean_up_dangling_images if ret_val == true
#    return ret_val
  rescue StandardError => e
    container.last_error = ('Failed To Delete ' + e.to_s)
    log_exception(e)
  end

  #  def docker_exec(container, command, args)
  #    run_args = 'docker exec ' + container.container_name + ' ' + command + ' ' + args
  #    execute_docker_cmd(run_args, container)
  #  end

  def clean_up_dangling_images
  images =  @docker_comms.find_images('dangling=true')
    images.each do |image|
      next unless image.is_a?(Hash) && image.key?('Id')
      @docker_comms.delete_image(image['Id'])
    end
#    cmd = 'docker rmi $( docker images -f \'dangling=true\' -q) &'
#    Thread.new { SystemUtils.execute_command(cmd) }
    return true # often warning not error
    rescue StandardError => e
     
      log_exception(e)
  end

end