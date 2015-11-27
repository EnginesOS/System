module DockerImages

  require_relative 'docker_exec.rb'
  def pull_image(image_name)
    cmd = 'docker pull ' + image_name
    SystemUtils.debug_output('Pull Image', cmd)
    result = SystemUtils.execute_command(cmd)
    @last_error = result[:stdout]
    if result[:result] != 0
      return true if result[:stdout].include?('Status: Image is up to date for ' + image_name) == true
      @last_error += ':' + result[:stderr].to_s
      return false
    end
    return true if result[:stdout].include?('Status: Image is up to date for ' + image_name) == true
    @last_error += ':' + result[:stderr].to_s
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def image_exist?(imagename)
    image_name = imagename.gsub(/:.*$/, '')
    cmd = 'docker images -q ' + image_name
    result = SystemUtils.execute_command(cmd)
    #    @last_error = result[:stderr].to_s
    return false if result[:result] != 0
    return true if result[:stdout].length > 4
    return false # Otherwise returnsresult[:stdout]
  rescue StandardError => e
    log_exception(e)
  end

  def delete_image(container)
    clear_error
    commandargs = 'docker rmi -f ' + container.image
    ret_val =  run_docker_cmd(commandargs, container)
    wait_for_docker_event(:stop, container) if ret_val == true
    clean_up_dangling_images if ret_val == true
    return ret_val
  rescue StandardError => e
    container.last_error = ('Failed To Delete ' + e.to_s)
    log_exception(e)
  end

  #  def docker_exec(container, command, args)
  #    run_args = 'docker exec ' + container.container_name + ' ' + command + ' ' + args
  #    execute_docker_cmd(run_args, container)
  #  end

  def clean_up_dangling_images
    cmd = 'docker rmi $( docker images -f \'dangling=true\' -q) &'
    Thread.new { SystemUtils.execute_command(cmd) }
    return true # often warning not error
  end

end