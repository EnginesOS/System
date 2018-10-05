module ServiceApiConfigurations
  @@configurator_timeout = 10
  def retrieve_configurator(c, params)
    cmd = '/home/engines/scripts/configurators/read_' + params[:configurator_name].to_s + '.sh'
    result =  @engines_core.exec_in_container(
    {container: c,
      command_line: [cmd],
      log_error: true,
      timeout: @@configurator_timeout})
    if result[:result] == 0
      variables_hash = deal_with_json(result[:stdout])
      params[:variables] = symbolize_keys(variables_hash)
      params
    else
      raise EnginesException.new(error_hash('Error on retrieving Configuration', result))
    end
  end

  def run_configurator(c, configurator_params)
    if c.is_running?
      #  STDERR.puts( "CONFIGURAT[:variables].to_json " + configurator_params[:variables].to_json.to_s)
      cmd = ['/home/engines/scripts/configurators/set_' + configurator_params[:configurator_name].to_s + '.sh']
      #  STDERR.puts( 'CONFIGURAT cmd /home/engines/scripts/configurators/set_' + configurator_params[:configurator_name].to_s + '.sh')
      #cmd = 'docker_exec -u ' + container.cont_user_id.to_s + ' ' +  container.container_name.to_s + ' /home/engines/scripts/configurators/set_' + configurator_params[:configurator_name].to_s + '.sh \'' + SystemUtils.hash_variables_as_json_str(configurator_params).to_s + '\''
      @engines_core.exec_in_container(
      {container: c,
        command_line: cmd,
        log_error: true,
        timeout: @@configurator_timeout,
        data: configurator_params[:variables].to_json })
    else
      {stderr: 'Not Running', result: -1}
    end
  end

  def update_service_configuration(configuration)
    @engines_core.update_service_configuration(configuration)
  end

  def pending_service_configurations_hashes(service_hash)
    ph = @engines_core.pending_service_configurations_hashes(service_hash)
  #  STDERR.puts(' pENDINED SERVICSE ' + ph.to_s)
    ph
  end

  #({service_name: @container_name})
  def retrieve_service_configurations(configurator_params)
    @engines_core.retrieve_service_configurations(configurator_params)
  end

  #({service_name: @container_name})
  def retrieve_service_configuration(configurator_params)
    @engines_core.retrieve_service_configuration(configurator_params)
  end

  def service_resource(c, what)
    cmd = '/home/engines/scripts/services/resources/' + what + '.sh'
    # STDERR.puts('SERVICE RESOURCE' + cmd.to_s)
    #  STDERR.puts('SERVICE RESOURCE' + c.container_name)
    @engines_core.exec_in_container(
    {container: c,
      command_line: cmd,
      log_error: true,
      timeout: @@configurator_timeout,
      data: nil})[:stdout]
  end

end 