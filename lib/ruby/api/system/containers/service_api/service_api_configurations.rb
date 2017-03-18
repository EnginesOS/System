module ServiceApiConfigurations
  @@configurator_timeout = 10
  def retrieve_configurator(c, params)
    # cmd = 'docker_exec -u ' + c.cont_userid + ' ' +  c.container_name + ' /home/configurators/read_' + params[:configurator_name].to_s + '.sh '
    cmd =  '/home/configurators/read_' + params[:configurator_name].to_s + '.sh'
    result =  @engines_core.exec_in_container({:container => c, :command_line => [cmd], :log_error => true, :timeout => @@configurator_timeout})
    if result[:result] == 0
      #variables = SystemUtils.hash_string_to_hash(result[:stdout])
      #FIXMe dont use JSON.pars
      variables_hash = deal_with_json(result[:stdout])
      params[:variables] = symbolize_keys(variables_hash)
      return params
    end
    raise EnginesException.new(error_hash('Error on retrieving Configuration', result))
  end

  def run_configurator(c, configurator_params)
    return {stderr: 'Not Running', result: -1} unless c.is_running?
    #  STDERR.puts( "CONFIGURAT[:variables].to_json " + configurator_params[:variables].to_json.to_s)
    cmd = ['/home/configurators/set_' + configurator_params[:configurator_name].to_s + '.sh']
    #  STDERR.puts( 'CONFIGURAT cmd /home/configurators/set_' + configurator_params[:configurator_name].to_s + '.sh')
    #cmd = 'docker_exec -u ' + container.cont_userid.to_s + ' ' +  container.container_name.to_s + ' /home/configurators/set_' + configurator_params[:configurator_name].to_s + '.sh \'' + SystemUtils.hash_variables_as_json_str(configurator_params).to_s + '\''
    result = @engines_core.exec_in_container({:container => c, :command_line => cmd, :log_error => true , :timeout => @@configurator_timeout, :data=> configurator_params[:variables].to_json })
    @last_error = result[:stderr] unless result.is_a?(EnginesError)# Dont log just set
    result
  end

  def update_service_configuration(configuration)
    engines_core.update_service_configuration(configuration)
  end

  def get_pending_service_configurations_hashes(service_hash)
    engines_core.get_pending_service_configurations_hashes(service_hash)
  end

  #({service_name: @container_name})
  def get_service_configurations_hashes(service_hash)
    engines_core.get_service_configurations_hashes(service_hash)
  end
end 