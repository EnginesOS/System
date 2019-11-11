module ServiceDockConfigurations
  @@configurator_timeout = 10
  def retrieve_configurator(c, params)
    cmd = "/home/engines/scripts/configurators/read_#{params[:configurator_name]}.sh"
    result =  dock_face.docker_exec(
    {container: c,
      command_line: [cmd],
      log_error: true,
      timeout: @@configurator_timeout})
    if result[:result] == 0
      parser = Yajl::Parser.new({:symbolize_keys => true})
      params[:variables] = parser.parse(result[:stdout])
   #  variables_hash = deal_with_json(result[:stdout])
   #   params[:variables] = symbolize_keys(variables_hash)
      params
    else
      raise EnginesException.new(error_hash('Error on retrieving Configuration', result))
    end
  end

  def run_configurator(c, configurator_params)
    if c.is_running?
      cmd = ["/home/engines/scripts/configurators/set_#{configurator_params[:configurator_name]}.sh"]
      dock_face.docker_exec(
      {container: c,
        command_line: cmd,
        log_error: true,
        timeout: @@configurator_timeout,
        configuration: configurator_params[:variables]})
        #data: configurator_params[:variables].to_json })
    else
      {stderr: 'Not Running', result: -1}
    end
  end

  def update_service_configuration(configuration)
    core.update_service_configuration(configuration)
  end

  def pending_service_configurations_hashes(service_hash)
    ph = core.pending_service_configurations_hashes(service_hash)
  #  STDERR.puts(' pENDINED SERVICSE ' + ph.to_s)
    ph
  end

  #({service_name: @container_name})
  def retrieve_service_configurations(configurator_params)
    core.retrieve_service_configurations(configurator_params)
  end

  #({service_name: @container_name})
  def retrieve_service_configuration(configurator_params)
    core.retrieve_service_configuration(configurator_params)
  end

  def service_resource(c, what)
  cmd = "/home/engines/scripts/services/resources/#{what}.sh"
    # STDERR.puts('SERVICE RESOURCE' + cmd.to_s)
    #  STDERR.puts('SERVICE RESOURCE' + c.container_name)
    dock_face.docker_exec(
    {container: c,
      command_line: cmd,
      log_error: true,
      timeout: @@configurator_timeout,
      data: nil})[:stdout]
  end

end
