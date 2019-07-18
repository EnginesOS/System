module DockerOperations
  # require '/opt/engines/lib/ruby/api/system/docker/docker_api.rb'
  # @returns [Boolean]
  # whether pulled or no false if no new image
  def pull_image(image_name)
    @docker_api.pull_image(image_name)
  end

  def clean_up_dangling_images
    @docker_api.clean_up_dangling_images
  end

  def exec_in_container(params)
    params[:background] = false unless params.key?(:background)
    STDERR.puts('EXEC IN CONTAINER PARAMS ' + params.keys.to_s)
    STDERR.puts('Time Out ' + params[:timeout].to_s)
    Timeout.timeout(params[:timeout] + 2) do # wait 1 sec longer incase another timeout prior
      @docker_api.docker_exec(params)
    end
  rescue Timeout::Error
    #FIX ME and kill process
    r = {}
    r[:result] = -1;
    r[:stderr] = 'Timeout on Docker exec :' + params[:command_line].to_s + ':' + result[:container].container_name.to_s
    STDERR.puts(' Timeout ' + r.to_s)
    raise EnginesException.new(warning_hash('Timeout on Docker exec', r))
  end

  def container_name_and_type_from_id(id)
    @docker_api.container_name_and_type_from_id(id)
  end
end