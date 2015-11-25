module ServiceApiConfigurations
  @@script_timeout=5
 
  def retrieve_configurator(c, params)
    cmd = 'docker exec -u ' + c.cont_userid + ' ' +  c.container_name + ' /home/configurators/read_' + params[:configurator_name].to_s + '.sh '
    result = {}
      begin
    Timeout.timeout(@@script_timeout) do 
      thr = Thread.new { result = SystemUtils.execute_command(cmd) }
      thr.join
    end
      rescue Timeout::Error
        log_error_mesg('Timeout on  retrieving Configuration',cmd)
        return {}
     end
      
    if result[:result] == 0
      variables = SystemUtils.hash_string_to_hash(result[:stdout])
      params[:variables] = variables
      return params
    end
    log_error_mesg('Error on retrieving Configuration',result)
    return {}
  end

  def run_configurator(container, configurator_params)
     
      cmd = 'docker exec -u ' + container.cont_userid.to_s + ' ' +  container.container_name.to_s + ' /home/configurators/set_' + configurator_params[:configurator_name].to_s + '.sh \'' + SystemUtils.service_hash_variables_as_str(configurator_params).to_s + '\''
      result = {}
    begin
  Timeout.timeout(@@script_timeout) do 
      thr = Thread.new { result = SystemUtils.execute_command(cmd) }
      thr.join
    end
      rescue Timeout::Error
        log_error_mesg('Timeout on running configurator',cmd)
        return {}
     end
      @last_error = result[:stderr] # Dont log just set
      return result
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