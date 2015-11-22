module ServiceConfigurations
 include CoreAccess
 
  def retrieve_configurator(c, params)
    return log_error_mesg('service not running ',params) if c.is_running? == false
    return log_error_mesg('service missing cont_userid ',params) if c.check_cont_uid == false
    cmd = 'docker exec -u ' + c.cont_userid + ' ' +  c.container_name + ' /home/configurators/read_' + params[:configurator_name].to_s + '.sh '
    result = {}
    thr = Thread.new { result = SystemUtils.execute_command(cmd) }
    thr.join
    if result[:result] == 0
      variables = SystemUtils.hash_string_to_hash(result[:stdout])
      params[:variables] = variables
      return params
    end
    log_error_mesg('Failed retrieve_configurator',result)
    return {}
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